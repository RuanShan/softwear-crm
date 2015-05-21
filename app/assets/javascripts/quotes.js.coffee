jQuery -> 
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
