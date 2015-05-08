class ImprintDrop < Liquid::Drop

  def initialize(impint)
    @impint = impint
  end

  def imprint_method
    @impint.imprint_method.name
  end

  def imprint_location
    @impint.print_location.name
  end

  def description
    @imprint.description
  end

end