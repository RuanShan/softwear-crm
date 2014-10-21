String.class_eval do
  def last(*args)
    if args.empty?
      self[-1]
    else
      amount = args.first
      start_index = size - amount
      self[start_index..-1]
    end
  end

  def a_or_an
    (%w(a e i o u).include?(downcase.first) ? 'an ' : 'a ') + self
  end

  def whitespace?
    self =~ /^\s*$/
  end
end

Hash.class_eval do
  alias_method :+, :merge
end
