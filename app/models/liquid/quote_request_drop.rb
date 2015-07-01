class QuoteRequestDrop < Liquid::Drop
  def initialize(qr)
    @quote_request = qr
  end

  QuoteRequest.column_names.each do |field|
    unless /_id$/ =~ field
      define_method field do
        @quote_request.send(field)
      end
    end
  end

  def salesperson_first_name
    @quote_request.salesperson.try(:first_name)
  end

  def salesperson_last_name
    @quote_request.salesperson.try(:last_name)
  end
end
