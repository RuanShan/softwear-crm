require 'spec_helper'

describe NameNumber, name_number_spec: true do
  describe 'Relationships' do
    context 'when testing story_189', story_189: true do
      it { is_expected.to belong_to :imprint }
      it { is_expected.to belong_to :imprintable_variant }
    end
  end

  describe 'Validations' do
    context 'when testing story_190', story_190: true do
      it { is_expected.to validate_presence_of :imprint_id }
      it { is_expected.to validate_presence_of :imprintable_variant_id }
    end
  end
end
