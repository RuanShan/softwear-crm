class OrderMailer < ActionMailer::Base
  def invoice_rejected(order, link)
    mail(
      from:    'noreply@softwearcrm.com',
      to:      order.salesperson.email,
      subject: %<Order Invoice ##{order.id} "#{order.name}" has been Rejected>,
      body:    "#{order.full_name}'s reason: #{order.invoice_reject_reason}\n\n#{link}"
    )
  end

  def invoice_approved(order, link)
    mail(
      from:    'noreply@softwearcrm.com',
      to:      order.salesperson.email,
      subject: %(Order Invoice ##{order.id} "#{order.name}" has been Approved),
      body:    "Good job!\n\n#{link}"
    )
  end
end
