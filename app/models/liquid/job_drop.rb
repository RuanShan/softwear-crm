class JobDrop < Liquid::Drop

  def initialize(job)
    @job = job
  end

  def name
    @job.name
  end

  def description
    @job.description
  end

  def line_items
    @job.line_items.map{|li| LineItemDrop.new(li)}
  end

  def imprints
    @job.imprints.map{|i| ImprintDrop.new(i)}
  end

  def imprintable_tiers
    Imprintable::TIERS.map{|number, name| ImprintableTierDrop.new(number: number, name: name, job: @job)}
  end

  def additional_options_and_markups
    @job.additional_options_and_markups.map{|li| LineItemDrop.new(li) }
  end
end

