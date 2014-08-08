jQuery ->
  #TODO ensure proper usage with global datetimepicker
  $('.datetimepicker').datetimepicker()

  #TODO make global exists in orders
  $("#quotesWizard").easyWizard
    buttonsClass: "btn btn-default"
    submitButtonClass: "btn btn-primary"

    #TODO should work if submit button is in form, don't need
  $(document).on 'click', '#email-form-submit-button', submitSummernote

  return

  #TODO use summernoteSubmit in global
@submitSummernote = ->
  summer_note = $('.summernote')
  summer_note.val summer_note.code()

@printPage = ->
  window.print()

  # TODO if using js responses, this can be refactored
@refreshQuote = (quoteId) ->
  ajax = $.ajax
    type: 'GET'
    url: Routes.quote_path(quoteId)
    dataType: 'json'

  ajax.done (response) ->
    console.log response.content
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

  #TODO descriptive variable?
@registerQuoteEvents = ($c) ->
  refresh_inlines()
  $quoteCollapse = $c.find('.quote-collapse')

  $quoteCollapse.off 'show.bs.collapse', onQuoteCollapseShow
  $quoteCollapse.off 'hide.bs.collapse', onQuoteCollapseHide

  $quoteCollapse.on 'show.bs.collapse', onQuoteCollapseShow
  $quoteCollapse.on 'hide.bs.collapse', onQuoteCollapseHide
