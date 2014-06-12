require 'spec_helper'

describe Imprint, imprint_spec: true do
  5.times do |n|
    let("print_location#{n+1}") { create(:print_location) }
  end
  2.times do |n|
    let("imprint_method#{n+1}") { create(:valid_imprint_method) }
  end

  it 'should have many print_locations' do
    expect { subject.print_locations }.to_not raise_error
    expect(subject.print_locations).to be_a ActiveRecord::Relation
  end

  it 'should assure that its print locations are all valid with its imprint_method' do
    print_location1.imprint_method_id = imprint_method1.id
    print_location2.imprint_method_id = imprint_method1.id
    print_location3.imprint_method_id = imprint_method2.id
    print_location4.imprint_method_id = imprint_method2.id
    subject = create(:imprint, imprint_method_id: imprint_method1.id)

    subject.print_locations << print_location1
    expect(subject).to be_valid
    subject.print_locations << print_location2
    expect(subject).to be_valid
    subject.print_locations << print_location3
    expect(subject).to_not be_valid
  end
end
