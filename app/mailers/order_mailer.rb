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

  def payment_made(order, payment, link)
    @order = order
    @payment = payment
    @link = link

    mail(
      from:    'sales@annarbortees.com',
      to:      order.email,
      subject: %(Thank you for your payment on Order ##{order.id} "#{order.name}")
    )
  end
end
