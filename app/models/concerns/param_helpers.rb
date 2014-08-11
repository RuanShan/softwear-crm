module ParamHelpers
  extend ActiveSupport::Concern

  def param_record_id(possible_record)
    possible_record.try(:id) || possible_record
  end

  def param_record(model, possible_record)
    case possible_record
    when model then possible_record
    else model.find possible_record
    end
  end
end