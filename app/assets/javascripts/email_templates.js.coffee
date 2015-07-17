jQuery ->
  setRef = (element) ->
    $('.type-ref').hide()
    if element.val() is 'Quote'
      $('.quote-ref').show()
    if element.val() is 'QuoteRequest'
      $('.quote-request-ref').show()


  if $('.template-type-select').length isnt 0
    setRef($('.template-type-select'))

  $('.template-type-select').change ->
    setRef($(this))

@prepareFreshdeskSelect = ->
  $(".freshdesk-select").click ->
    SelectText('freshdesk-email-temp')
