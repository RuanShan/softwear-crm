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
end