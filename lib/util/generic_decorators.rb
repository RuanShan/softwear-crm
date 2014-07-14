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
end

Hash.class_eval do
  alias_method :+, :merge
end

Array.class_eval do
  def combine(method_name=nil, &block)
    if method_name
      return combine do |total, entry|
        total.method(method_name.to_sym).call(entry)
      end
    end

    total = first
    self[1..-1].each do |entry|
      total = yield total, entry
    end
    total
  end
end