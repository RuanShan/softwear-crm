require 'spec_helper'

describe 'imprintables/show/_retail.html.erb', imprintable_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    allow(imprintable).to receive(:name).and_return('name')
    render 'imprintables/show/retail', imprintable: imprintable
  end

  it 'display main supplier, supplier link, name, and pricing' do
    expect(rendered).to have_css('dd', text: imprintable.common_name)
    expect(rendered).to have_css('dd', text: imprintable.sku)
  end
end
