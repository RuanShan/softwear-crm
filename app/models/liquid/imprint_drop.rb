class ImprintDrop < Liquid::Drop

  def initialize(imprint)
    @imprint = imprint
  end

  def imprint_method
    @imprint.imprint_method.name
  end

  def imprint_location
    @imprint.print_location.name
  end

  def description
    @imprint.description
  end

end
