module ErrorCatcher
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, StandardError, with: :error_report_form
  end

  protected

  def error_report_form(error)
    Rails.logger.error "**** #{error.class.name}: #{error.message} ****\n\n"\
      "\t#{error.backtrace.join("\n\t")}"

    @error = error
    @additional_info = gather_additional_info

    begin
      respond_to do |format|
        format.html { render 'errors/internal_server_error', status: 500 }
        format.js   { render 'errors/internal_server_error', status: 500 }
        format.json { render json: '{}', status: 500 }
      end
    rescue AbstractController::DoubleRenderError => e
      Rails.logger.error "DOUBLE RENDER ERROR IN CONTROLLER ERROR CATCHER!!! #{e.message}"
    end
  end

  def gather_additional_info
    JSON.pretty_generate(params) + "|||" +
    instance_variables
      .reject { |v| /^@_/ =~ v.to_s || %i(@view_renderer @output_buffer @view_flow @error).include?(v) }
      .map { |v| "#{v}: #{instance_variable_get(v).inspect}" }
      .join("|||")
  end
end
