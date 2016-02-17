module BelongsToUser
  extend ActiveSupport::Concern

  module ClassMethods
    def belongs_to_user_called(name, options = {})
      foreign_key = "#{name}_id"

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          @#{name} ||= User.find(#{name}_id)
        end

        def #{name}=(new)
          self.#{foreign_key} = new.id
          @#{name} = new
        end
      RUBY
    end

    def belongs_to_user
      belongs_to_user_called(:user)
    end
  end

  included do
    extend ClassMethods
  end
end
