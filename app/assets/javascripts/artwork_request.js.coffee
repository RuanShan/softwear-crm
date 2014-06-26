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
      data: currentForm().serialize() + escape($('.summernote').code())
      dataType: 'json'
    ajax.done (response) ->
      if response.result == 'success'
        console.log 'Successfully created artwork request!'
#        artworkRequestId = action.charAt(action.indexOf('artwork_requests/')+'artwork_requests/'.length)
#        @refreshArtworkRequest artworkRequestId
        artworkRequestModal.modal 'hide'

      else if response.result == 'failure'
        console.log 'Failed to create'
        errorHandler ||= ErrorHandler('artwork_request', currentForm())
        errorHandler.handleErrors(response.errors, response.modal)

    ajax.fail (jqXHR, textStatus) ->
      alert "Something's wronga with the server!"

  artworkRequestModal.keyup (key) ->
    $('#artwork-request-submit').click() if key.which is 13 # enter key


$(document).ready ->
#  input = $("<input>").attr("type", "hidden").escape($('.summernote').code())
#  $("#artwork-request-submit").append $(input)
#
#  $("#artwork-request-submit").submit ->
#    $('<input />').attr('type', 'hidden').escape($('.summernote').code()).appendTo "#artwork-request-submit"

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