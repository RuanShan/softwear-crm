module TimelineHelper
  def update_order_timeline(order = nil)
    return unless order || @order
    unless @request_time
      raise "@request_time is required to update the timeline from server side"
    end
    
    activities =
      (order || @order).all_activities.where(
        "created_at > ?", @request_time.to_s(:db)
      )

    render(
      partial:  'shared/new_activities',
      locals:   { activities: activities }
    )
  end

  def render_freshdesk_note(html)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    doc.css('blockquote.freshdesk_quote').each do |node|
      p = Nokogiri::XML::Node.new "p", doc
      link = Nokogiri::XML::Node.new('a', p)
      link['href'] = '#'
      link.content = 'Toggle Quoted Text'
      link['class'] = 'freshdesk-toggle-quoted btn btn-primary btn-sm'
      p.add_child link
      node.add_previous_sibling(p)
    end
    doc.to_html.html_safe
  end

end
