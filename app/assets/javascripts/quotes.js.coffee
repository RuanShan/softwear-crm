jQuery ->

  $('.freshdesk-toggle-quoted').click ->
    $(this).parent().siblings("blockquote").toggle()

  #This function checks if an Insightly bid estimate is in a certain tier
  $('#quote_insightly_value').change ->
    dollar = $('#quote_insightly_value').val()
    $('#quote_insightly_bid_tier_id').children().each ->
      tier = $(this).text()
      if tier != 'unassigned'
        array = tier.split(" ")
        low = array[3]
        low = low.substr(2)
        high = array[5]
        high = high.substr(1, high.lastIndexOf(')')-1)
        min = parseInt(low,10)
        if isNaN(parseInt(high, 10)) == true
          max = Infinity
        else
          max = parseInt(high,10)
        if dollar <= max && dollar >= min
          $("#quote_insightly_bid_tier_id" ).val($(this).val())
          $("#quote_insightly_bid_amount").val(dollar)

  $('#quote_deadline_is_specified').change ->
    if $(this).val() == 'true'
      $("label[for='quote_estimated_delivery_date']").text("Delivery Date")
    else
      $("label[for='quote_estimated_delivery_date']").text("Estimated Delivery Date")
 
  $(document).on('click', '#print-button', ->
    printPage()
  )
  
  if document.URL.match(/print=true/)
    window.print()
    return false

  $('.js-datetimepicker').datetimepicker()

@invalidMsg = (textbox) ->
  if textbox.validity.patternMismatch
    textbox.setCustomValidity('Please format like so "Example Email <example@email.com>, Example Two <example@two.com>"')
  else
    textbox.setCustomValidity('')
  true

@printPage = ->
  window.print()
  return false

  # TODO if using js responses, this can be refactored
@refreshQuote = (quoteId) ->
  ajax = $.ajax
    type: 'GET'
    url: Routes.quote_path(quoteId)
    dataType: 'json'

  ajax.done (response) ->
    #console.log response.content
    $('#replaceable').replaceWith response.content
    refresh_inlines()

  ajax.fail (jqXHR, textStatus) ->
    alert "Failed to re-render quote #{quoteId}. Refresh the page to view changes."

    # TODO same as above if js responses
quoteCollapse = (id, collapsed) ->
  ajax = $.ajax
    type: 'PUT'
    url: Routes.quote_path(id)
    data: { 'quote[collapsed]': collapsed.toString() }
    dataType: 'json'

  ajax.done (response) ->
    unless response.result is 'success'
      errorModal "The quote couldn't be saved!"

  ajax.fail (jqXHR, textStatus) ->
    errorModal 'Either the server is messed up, or your internet is down!'

@onQuoteCollapseShow = ->
  quoteCollapse $(this).data('quote-id'), true

@onQuoteCollapseHide = ->
  quoteCollapse $(this).data('quote-id'), false

  # TODO descriptive variable?
@registerQuoteEvents = ($c) ->
  refresh_inlines()
  $quoteCollapse = $c.find('.quote-collapse')

  $quoteCollapse.off 'show.bs.collapse', onQuoteCollapseShow
  $quoteCollapse.off 'hide.bs.collapse', onQuoteCollapseHide

  $quoteCollapse.on 'show.bs.collapse', onQuoteCollapseShow
  $quoteCollapse.on 'hide.bs.collapse', onQuoteCollapseHide

@initializeQuoteSelectChosen = ->
  $("#quote_id").chosen
    no_results_text: "No results matched"
    width: "400px"
