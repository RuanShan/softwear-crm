module Sunspot
  module Type
    class ReferenceType < AbstractType
      def cast(string)
        data = string.split '_'
        Kernel.const_get(data[0]).find(data[1])
      end
      def to_indexed(value)
        "#{value.class.name}_#{value.id}_ref"
      end
      def indexed_name(name)
        "#{name}_ref"
      end
    end
    register(ReferenceType, ActiveRecord::Base)
  end
end