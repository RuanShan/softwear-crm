$(window).load ->
  $("#flashModal").modal "show"
  $("#errorsModal").modal "show"
  return

$(document).ready ->
  $('.format-phone').mask("999-999-9999")
  return

@shine = (element, returnDefault) ->
  returnDefault = false if returnDefault is null
  $element = $(element)
  returnColor = 'default'
  returnColor = $element.css('background-color') unless returnDefault
  $element.css('background-color', '#99ffbb')
  $element.animate {backgroundColor: returnColor}, 1000, -> $element.css 'background-color', ''

# Call this to invoke an error modal, sort of like alert
# body parameter is optional, title will default to "Error"
@errorModal = (titleOrBody, body) ->
  title = 
    if body
      titleOrBody
    else
      body = titleOrBody
      "Error"

  $('#genericErrorModal').modal 'hide'
  $('#genericErrorTitle').text title
  $('#genericErrorBody').text body
  $('#genericErrorModal').modal 'show'

# Modal alternative to confirm() except you pass a function
# rather than call as a conditional.
# 
# With the callback, you can either pass a parameterless 
# function that will only be called when 'confirm' is clicked,
# or a single-parameter function where the parameter will
# be true or false depending on the user's response.
@confirmModal = (question, callback) ->
  $modal = $('#contentModal')
  $('#contentTitle').text 'Confirm'
  $('#contentBody').text question

  $yesBtn = $ '<a class="btn btn-primary" id="modal-confirm-btn">Confirm</a>'
  $noBtn  = $ '<a class="btn btn-default" id="modal-cancel-btn">Cancel</a>'

  $footer = $('#contentFooter')
  $footer.children().remove()
  $footer.append $yesBtn
  $footer.append $noBtn

  $yesBtn.click ->
    $modal.modal 'hide'
    if callback.length == 0
      callback()
    else
      callback(true)
  $noBtn.click ->
    $modal.modal 'hide'
    if callback.length >= 1
      callback(false)

  onHide = -> 
    console.log 'hidden after confirm!'
    $('#contentModal > .modal-dialog').removeClass 'modal-sm'
    $modal.unbind 'hidden.bs.model', onHide
  $('#contentModal > .modal-dialog').addClass 'modal-sm'
  $modal.on 'hidden.bs.modal', onHide

  $modal.modal 'show'
