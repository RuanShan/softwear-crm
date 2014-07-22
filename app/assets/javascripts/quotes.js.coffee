jQuery ->
  $('.datetimepicker').datetimepicker()

  $("#quotesWizard").easyWizard
    buttonsClass: "btn btn-default"
    submitButtonClass: "btn btn-primary"

  return

@refreshQuote = (quoteId) ->

  ajax = $.ajax
    type: 'GET'
    url: Routes.quote_path(quoteId)
    dataType: 'json'

  ajax.done (response) ->
    $('#replaceable').replaceWith response.content
    refresh_inlines()

  ajax.fail (jqXHR, textStatus) ->
    alert "Failed to re-render quote #{quoteId}. Refresh the page to view changes."

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

@registerQuoteEvents = ($c) ->
  refresh_inlines()
  $quoteCollapse = $c.find('.quote-collapse')

  $quoteCollapse.off 'show.bs.collapse', onQuoteCollapseShow
  $quoteCollapse.off 'hide.bs.collapse', onQuoteCollapseHide

  $quoteCollapse.on 'show.bs.collapse', onQuoteCollapseShow
  $quoteCollapse.on 'hide.bs.collapse', onQuoteCollapseHide

#  clearFormInputs = ($formDiv) ->
#    $formDiv.find('input:text, select, textarea, input[type="number"]').val('')
#    $formDiv
#
#  $('#line_item_creation').change ->
#    if $(this).val() == 'Yes'
#      # clone #li-imprintable-form
#      $li_imprintable_form = $('#li-imprintable-form')
#      # append
#      $li_imprintable_form.clone().attr('id', '').append($('#line-item-container')).show()
#      # set display
#      # remove id
#    else
#      # clone #li-standard-form
#      $li_standard_form = $('#li-standard-form')
#      $clone = clearFormInputs($li_standard_form.clone().attr('id', ''))
#      $('#line-item-container').append($clone.show())
#
#    document.getElementById('line_item_creation').selectedIndex = 0

