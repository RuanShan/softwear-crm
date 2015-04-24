module InsightlyHelper
  def insightly_categories
    return nil unless insightly_available?

    begin
      insightly.get_task_categories.map { |t| [t.category_name, t.category_id] }
    rescue Insightly2::Errors::ClientError
      @insightly_errored = true
      nil
    end
  end

  def insightly_pipelines
    return nil unless insightly_available?

    begin
      insightly.get_pipelines.map { |t| [t.pipeline_name, t.pipeline_id] }
    rescue Insightly2::Errors::ClientError
      @insightly_errored = true
      nil
    end
  end

  def insightly_opportunity_profiles
    return nil unless insightly_available?

    begin
      insightly.get_custom_field(id: 'OPPORTUNITY_FIELD_12')
        .custom_field_options
        .map { |f| [f['option_value'], f['option_id']] }
    rescue Insightly2::Errors::ClientError
      @insightly_errored = true
      nil
    end
  end

  def insightly_bid_tiers
    return nil unless insightly_available?

    begin
      insightly.get_custom_field(id: 'OPPORTUNITY_FIELD_11')
        .custom_field_options
        .map { |f| [f['option_value'], f['option_id']] }
    rescue Insightly2::Errors::ClientError
      @insightly_errored = true
      nil
    end
  end

  def insightly_select(f, field, options)
    f.select field, options_for_select(options || [], f.object.send(field)), {}, { disabled: disable_insightly_fields? }
  end

  def insightly_field(f, type, field)
    f.send("#{type}_field", field, { disabled: disable_insightly_fields? })
  end

  def insightly_available?
    !current_user.insightly_api_key.blank?
  end

  def insightly
    if current_user.insightly_api_key
      @insightly ||= Insightly2::Client.new(current_user.insightly_api_key)
    end
  end

  def insightly_error?
    @insightly_errored
  end

  def disable_insightly_fields?
    !insightly_available? or insightly_error?
  end
end
