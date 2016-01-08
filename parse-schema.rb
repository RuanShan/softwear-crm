# "Parse" schema to get all table and column names!
module ActiveRecord
  class Schema
    FieldReader = Struct.new(:a, :target_fields) do
      def method_missing(name, *args)
        a << args.first if target_fields.include?(name)
      end
    end

    def self.define(*a, &block)
      @tables = []
      @columns = {}
      instance_eval(&block)
      puts "tables = %w(#{@tables.join(' ')})"
      puts ""
      puts "columns = #{@columns.inspect}"
    end

    def self.create_table(*args)
      @tables << args.first
      columns = []
      yield FieldReader.new(columns, %i(string))
      @columns[args.first] = columns unless columns.empty?
    end

    def self.method_missing(*)
    end
    def self.respond_to?(*)
      true
    end
  end
end

require_relative 'db/schema.rb'
