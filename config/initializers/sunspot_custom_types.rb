module Sunspot
  module Type
    class ReferenceType < AbstractType
      def cast(string)
        if string == "nil"
          nil
        else
          data = string.split '_'
          Kernel.const_get(data[0]).find(data[1])
        end
      end
      def to_indexed(value)
        if value.nil?
          "nil"
        else
          "#{value.class.name}_#{value.id}_ref"
        end
      end
      def indexed_name(name)
        "#{name}_ref"
      end
    end
    register(ReferenceType, ActiveRecord::Base)
  end
end