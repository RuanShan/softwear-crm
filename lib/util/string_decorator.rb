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
end