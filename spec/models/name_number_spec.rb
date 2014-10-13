require 'spec_helper'

describe NameNumber, name_number_spec: true do
  describe 'Relationships' do
    context 'when testing story_189', story_189: true do
      it { is_expected.to belong_to :imprint }
      it { is_expected.to belong_to :imprintable_variant }
    end
  end
end
