module Train
  extend ActiveSupport::Concern

  included do
    def self.site
      "#{super}/trains"
    end
  end
end
