# Normally, this validator just runs type === value, meaning when you pass a proc
# to content_type, all it gives you is the string ("image/png", for example). This
# patch gives you the string and the record if your proc takes 2 arguments. This
# allows Asset to validate that the content_type is equal to its allowed_content_type.

Paperclip::Validators::AttachmentContentTypeValidator.class_eval do
  def check(record, type, value)
    if type.respond_to?(:call) && type.arity == 2
      type.call(value, record)
    else
      type
    end
  end

  # Override (copy/paste)
  def validate_whitelist(record, attribute, value)
    #                                                         This used to just be type
    #                                                         -------------------------
    if allowed_types.present? && allowed_types.none? { |type| check(record, type, value) === value }
      mark_invalid record, attribute, allowed_types
    end
  end

  # Override (copy/paste)
  def validate_blacklist(record, attribute, value)
    #                                                            This used to just be type
    #                                                            -------------------------
    if forbidden_types.present? && forbidden_types.any? { |type| check(record, type, value) === value }
      mark_invalid record, attribute, forbidden_types
    end
  end
end
