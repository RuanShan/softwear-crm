# Calling this when asynchronously changing order related data would be nice.
@updateOrderTimeline = ->
  return if $('#order-page').length is 0
  orderId = $('#order-page').data('order-id')
  ajax = $.ajax
    type: 'GET'
    url: Routes.order_timeline_path(orderId)
    data: { after: $('#timeline .the-timeline ul').children().first().find('.the-date').data('date') }
    dataType: 'json'

  ajax.done (response) ->
    if response.result is 'success'
      $('#timeline .the-timeline ul').prepend response.content
      console.log 'updated timeline'
    else
      errorModal "Couldn't update the order timeline view. Refreshing should do it if you actually want to see the updated timeline.", force: false

  ajax.fail (jqXHR, textStatus) ->
    errorModal "Internal server error. If this is the only error you see, it's probably no big deal.", force: false

$(window).load ->
  # TODO is there commenting style?
  # FIXME 'this is a hack, the whole thing is a hack' - Nigel
  # Edit can't redirect, meaning it can't supply an anchor, so
  # we use data from the error modal to know which tab to switch 
  # to when the user submits bad data to an edit
  if $('#errorsModal').length > 0
    switch $('#errorsModal').attr 'resource'
      when 'order' then window.location.hash = 'details'

  if $('#order-page').length > 0
    inlineEditableCallbacks.push (success) ->
      updateOrderTimeline() if success

  $("a[data-toggle='tab']").click ->
    if window.location.hash.indexOf($(this).attr 'href') == -1
      window.location.hash = $(this).attr 'href'

  #TODO instead of Nigel's 'hack' possibly create a show for Job that would present relevant info
  if window.location.hash != ''
    dashIndex = window.location.hash.indexOf '-'
    target = window.location.hash
    data = null
    if dashIndex > 0
      data = target.split '-'
      target = data[0]

    tab = $("a[href='#{target}']")
    tab.trigger $.Event('click')

    # If data.length > 1, the url might look like: /orders/1/edit#jobs-2
    # In which case, we want to scroll to the entry for job with ID 2.
    if data && data.length > 1
      after 500, ->
        if target == '#jobs'
          shined = false
                                # Remember, data[0] is target
          $('.scroll-y').scrollTo $("#job-#{data[1]}").find('.job-title'),{
            duration: 1000,
            offsetTop: 100}, ->
              # If data.length > 3, the url might look like: /orders/3/edit#jobs-4-line_item-10
              # In which case, we want to shine the line item with id 10.
              if data.length > 3 and not shined
                if data[2] is 'line_item'
                  tryShineLineItem = ($lineItem) ->
                    if $lineItem.length == 0
                      false
                    else
                      shine $lineItem, null, 2000; true

                  tryShineLineItem($ "#line-item-#{data[3]}") or 
                    tryShineLineItem($("#edit-line-item-#{data[3]}").parentsUntil('.row').parent())
                  shined = true

                else if data[2] is 'imprint'
                  $imprint = $(".imprint-entry[data-id='#{data[3]}'] *")
                  $('.scroll-y').scrollTo $imprint,{
                    duration: 700
                    offsetTop: 300}, ->
                      shine $imprint, false, 2000
                      shined = true
