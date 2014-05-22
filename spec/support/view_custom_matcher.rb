require 'rspec/expectations'

RSpec::Matchers.define :have_text_input do
  match do |actual|
    expect(actual).to have_css('input', :type => 'text')
  end
end

RSpec::Matchers.define :have_select_input do
  match do |actual|
    expect(actual). to have_selector('select')
  end
end
