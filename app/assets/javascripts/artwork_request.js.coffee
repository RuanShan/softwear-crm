initializeArtworkRequestModal = (artworkRequestModal) ->
  $currentFormDiv = null
  currentForm = -> $currentFormDiv.find('form')

  errorHandler = null

  $('#artwork-request-submit').click ->
    $add = $(this)
    $add.attr 'disabled', 'disabled'
    setTimeout (-> $add.removeAttr 'disabled'), 5000

    errorHandler.clear() if errorHandler != null

    $currentFormDiv ||= $('#ar-standard-form')
    action = currentForm().attr('action')
    ajax = $.ajax
      type: 'POST'
      url: action
      data: currentForm().serialize()
      dataType: 'json'
    console.log(ajax)
    ajax.done (response) ->
      if response.result == 'success'
        console.log 'Successfully created artwork request!'
#        artworkRequestId = action.charAt(action.indexOf('artwork_requests/')+'artwork_requests/'.length)
#        @refreshArtworkRequests artworkRequestId
        artworkRequestModal.modal 'hide'

      else if response.result == 'failure'
        console.log 'Failed to create'
        errorHandler ||= ErrorHandler('artwork_request', currentForm())
        errorHandler.handleErrors(response.errors, response.modal)

    ajax.fail (jqXHR, textStatus) ->
      alert "Something's wronga with the server!"

  artworkRequestModal.keyup (key) ->
    $('#artwork-request-submit').click() if key.which is 13 # enter key

  artworkRequestModal.modal 'show'

#loadArtworkRequestView = (artworkRequestId, url) ->
#  $row = $("#artwork-request-#{artworkRequestId}")
#  $oldChildren = $row.children()
#  $row.load url, ->
#    $oldChildren.each -> $(this).remove()

#@editArtworkRequest = (artworkRequestId) ->
#  loadArtworkRequestView artworkRequestId, "/artwork_requests/#{artworkRequestId}/edit"
#
#@cancelEditArtworkRequest = (artworkRequestId) ->
#  loadArtworkRequestView artworkRequestId, "/artwork_requests/#{artworkRequestId}"
#
#@deleteArtworkRequest = (artworkRequestId) ->
#  $(this).attr 'disabled', 'disabled'
#
#  $row = $("#artwork-request-#{artworkRequestId}")
#  ajax = $.ajax
#
#    type: 'DELETE'
#    url: "/artwork_requests/#{artworkRequestId}"
#    dataType: 'json'
#
#  ajax.done (response) ->
#    if response.result == 'success'
#      $row.fadeOut -> $row.remove()
#    else if response.result == 'failure'
#      alert "Something weird happened and the artwork request couldn't be deleted."

#@updateArtworkRequests = (jobId) ->
#  $("#job-#{jobId} .editing-artwork-request").each (i) ->
#    $this = $(this)
#    ajax = $.ajax
#      type: 'PUT'
#      url: $this.attr 'action'
#      data: $this.serialize()
#      dataType: 'json'
#
#    ajax.done (response) ->
#      $container = $this.parent()
#      $container.children().each -> $(this).remove()
#      $content = $(response.content)
#      $container.append $content
#      if response.result == 'failure'
#        eh = ErrorHandler('artwork_request', $container.find('form'))
#        eh.handleErrors(response.errors, response.modal)
#      else
#        $inputs = $content.find 'input'
#        shine $inputs, true
#        shine $content, false
#
#    ajax.fail (jqXHR, errorText) ->
#      alert "Internal server error! Can't process request."

@addArtworkRequest = (orderID) ->
  $this = $(this)
  $this.attr 'disabled', 'disabled'
  setTimeout (-> $this.removeAttr 'disabled'), 1000

  ajax = $.ajax
    type: 'GET'
    url: "artwork_requests/new"
    data: {order_id: orderID}
    dataType: 'html'

  ajax.done (response) ->
    $('body').append $(response)

    summer_note = $('.summernote')
    summer_note.summernote
      height:300
    summer_note.code summer_note.val()
    summer_note.closest('form').submit ->
      summer_note.val summer_note.code()[0]

#    $(".summernote").summernote height: 200, toolbar: [['style', ['style']], ['style', ['bold', 'italic', 'underline', 'clear']], ['fontsize', ['fontsize']], ['color', ['color']], ['para', ['ul', 'ol', 'paragraph']], ['height', ['height']], ['insert', ['picture', 'link']], ['table', ['table']], ['help', ['help']]]
    $("#jobstokenfield").chosen
      placeholder_text_multiple: "Select all jobs for this request"
      no_results_text: "No results matched"
      width: "400px"
    artworkRequestModal = $('#artworkRequestModal')
    initializeArtworkRequestModal artworkRequestModal
    artworkRequestModal.on 'hidden.bs.modal', (e) ->
      artworkRequestModal.remove()

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error! Can't process request."

$(document).ready ->
  $(document).on "change", "#artwork_imprint_method_fields", (e) ->
    if $(this).find(":selected").attr("value")?
      ajax = $.ajax
        url: $(this).data("url") + "/" + $(this).find(":selected").attr("value")
        dataType: "script"
      ajax.done () ->
        $("input").iCheck
          checkboxClass: "icheckbox_minimal-grey"
          radioClass: "iradio_minimal-grey"
          increaseArea: "20%"