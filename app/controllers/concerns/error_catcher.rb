module ErrorCatcher
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, StandardError, with: :error_report_form unless Rails.env.test?
  end

  protected

  def error_report_form(error)
    Rails.logger.error "**** #{error.class.name}: #{error.message} ****\n\n"\
      "\t#{error.backtrace.join("\n\t")}"

    @error = error
    @additional_info = gather_additional_info

    begin
      respond_to do |format|
        format.html { render 'errors/internal_server_error', layout: layout_for_error, status: 500 }
        format.js   { render 'errors/internal_server_error', layout: layout_for_error, status: 500 }
        format.json { render json: '{}', status: 500 }
      end
    rescue AbstractController::DoubleRenderError => e
      Rails.logger.error "DOUBLE RENDER ERROR IN CONTROLLER ERROR CATCHER!!! #{e.message}"
    end
  end

  def filter_params(params)
    new_hash = {}
    params.each do |key, value|
      new_value = value

      case key.to_s
      when /cc_number/ then new_value = "<FILTERED>"
      when /cc_cvc/    then new_value = "<FILTERED>"
      when /password/  then new_value = "<FILTERED>"
      end

      new_hash[key] = new_value
    end
    new_hash
  end

  def gather_additional_info
    JSON.pretty_generate(filter_params(params)) + "|||" +
    instance_variables
      .reject { |v| /^@_/ =~ v.to_s || %i(@view_renderer @output_buffer @view_flow @error).include?(v) }
      .map { |v| "#{v}: #{instance_variable_get(v).inspect}" }
      .join("|||")
  end

  def layout_for_error
    current_user ? 'application' : 'no_overlay'
  end
end
