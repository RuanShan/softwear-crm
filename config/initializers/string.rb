class String
  def safely_constantize(list_of_klasses=[])
    list_of_klasses.each do |klass|
      return self.constantize if self == klass.to_s
    end
    raise "Not allowed to constantize #{self}."
  end
end
