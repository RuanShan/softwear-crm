module Popularity
  extend ActiveSupport::Concern

  module HasPopularity
    def popularity_rated_from(association)
      self.popularity_from_association = association

      default_scope { order(popularity: :desc) }
    end

    def has_popularity?
      !popularity_from_association.nil?
    end

    def update_popularity(id)
      find(id).update_popularity
    end
  end

  module RatesPopularity
    def rates_popularity_of(association)
      self.popularity_of_association = association

      after_save    :enqueue_update_associated_popularity
      after_destroy :enqueue_update_associated_popularity
    end

    def rates_popularity?
      !popularity_of_association.nil?
    end
  end

  included do
    cattr_accessor :popularity_of_association
    cattr_accessor :popularity_from_association

    extend Popularity::HasPopularity
    extend Popularity::RatesPopularity
  end

  def has_popularity?
    self.class.has_popularity?
  end
  def rates_popularity?
    self.class.rates_popularity?
  end

  def update_popularity
    if self.class.popularity_from_association.nil?
      raise "no popularity_from association set for #{model_name.element}"
    end
    self.popularity = send(self.class.popularity_from_association).where('updated_at > ?', 2.months.ago).size
    save!
  end

  def enqueue_update_associated_popularity
    if self.class.popularity_of_association.nil?
      raise "no popularity_of association set for #{model_name.element}"
    end
    # This is assumed to be a belongs_to association
    assoc = self.class.reflect_on_association(self.class.popularity_of_association)

    assoc_id = send(assoc.foreign_key)
    return if assoc_id.nil?

    # Delay on production, not on development or test
    target = Rails.env.production? ? assoc.klass.delay : assoc.klass
    target.update_popularity(assoc_id)
  end
end
