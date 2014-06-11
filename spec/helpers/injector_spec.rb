require 'spec_helper'

describe Injector do
  before(:each) do
    Injectable.TestInjectable do
      def inst_method
        'instance method'
      end
      def self.class_method
        'class method'
      end
      @class_var = test_method('hello')
    end unless Object.const_defined?(:TestInjectable)
  end

  let(:test_class) do
    Class.new do
      extend Injector
      def self.test_method(str)
        "hello #{str}"
      end
      inject TestInjectable
      def self.get_class_var
        @class_var
      end
    end
  end

  it 'should have its test_method called when the injection happens' do
    expect(test_class.get_class_var).to eq 'hello hello'
  end
  it 'should carry over defined instance methods' do
    expect{test_class.new.inst_method}.to_not raise_error
  end
  it 'should carry over defined class methods' do
    expect{test_class.class_method}.to_not raise_error
  end

  it 'should not alias methods' do
    expect{test_class.new.original_inst_method}.to raise_error
  end

  context 'when track_methods is true through inject options' do
    let(:tracked_class) do
      Class.new do
        extend Injector
        def self.test_method(str)
          "whatever #{str}"
        end
        inject TestInjectable, track_methods: true
      end
    end

    it "should alias the injectable's instance methods with original_ (no singleton for now)" do
      expect{tracked_class.new.original_inst_method}.to_not raise_error
    end
  end
end