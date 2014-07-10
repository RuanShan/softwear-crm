Hash.class_eval do
  alias_method :+, :merge
end