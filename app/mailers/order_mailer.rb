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
      from:    'noreply@softwearcrm.com',
      to:      order.email,
      subject: %(Thank you for your payment on Order ##{order.id} "#{order.name}")
    )
  end

  def imprintable_line_items_changed(order, crm_link, prod_link)
    return if order.nil?
    mail(
      from:    'noreply@softwearcrm.com',
      to:      %w(neworderreport@annarbortees.com league@annarbortees.com receiving@annarbortees.com),
      subject: %([Production Change] Imprintables changed for order ##{order.id} "#{order.name}"),
      body:    %(crm: #{crm_link}\nproduction: #{prod_link})
    )
  end
end
