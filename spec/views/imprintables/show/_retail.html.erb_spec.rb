require 'spec_helper'

describe 'imprintables/_supplier_details.html.erb', imprintable_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    allow(imprintable).to receive(:name).and_return('name')
    render partial: 'imprintables/supplier_details',
           locals: { imprintable: imprintable }
  end

  it 'display main supplier, supplier link, name, and pricing' do
    expect(rendered).to have_css('h2', text: imprintable.main_supplier)
  end
end
