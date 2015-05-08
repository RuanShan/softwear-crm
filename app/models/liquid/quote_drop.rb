class QuoteDrop < Liquid::Drop

  def initialize(quote)
    @quote = quote
  end

  def id
    @quote.id
  end

  def name
    @quote.name
  end

  def customer_first_name
    @quote.first_name
  end

  def customer_last_name
    @quote.first_name
  end

  def customer_full_name
    @quote.full_name
  end

  def customer_email
    @quote.email
  end

  def customer_company
    @quote.company
  end

  def customer_phone_number
    @quote.phone_number
  end

  def valid_until_date
    @quote.valid_until_date
  end

  def estimated_delivery_date
    @quote.estimated_delivery_date
  end

  def shipping_cost
    @quote.shipping
  end

  def jobs
    @quote.jobs.map{ |job| JobDrop.new(job) }
  end

  def formal
    @quote.formal?
  end

end

