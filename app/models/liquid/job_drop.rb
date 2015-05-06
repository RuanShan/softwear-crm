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
    @job.line_items.map{|li| JobDrop.new(li)}
  end

end

