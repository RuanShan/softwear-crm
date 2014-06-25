$(document).ready ->
  $contentModal = $('#contentModal')

  storeClassFor = ($elem) -> 
    $elem.data 'original-class', $elem.attr('class')
  retrieveClassFor = ($elem) ->
    unless typeof $elem.data('original-class') is 'undefined'
      $elem.attr 'class', $elem.data('original-class')

  storeClassFor $contentModal
  $('#contentModal *').each (index) ->
    storeClassFor $(this)

  # When the content modal is closed, clean up any alterations
  # to classes/content.
  $contentModal.on 'hidden.bs.modal', ->
    retrieveClassFor $contentModal
    $('#contentModal *').each ->
      retrieveClassFor $(this)
    $contentModal.find('.modal-content-area').empty()
    $contentModal.data 'open', false

  $contentModal.on 'show.bs.modal', ->
    $contentModal.data 'open', true

##
# Quick and easy way to show the content modal!
# 
# Valid options include: 'title', 'body', 'footer', and 'force'
# 
# Example (in coffeescript):
# ===============================
# setupContentModal ($contentModal) ->
#   $contentModal.find('.modal-dialog').addClass 'modal-lg'
# showContentModal
#   title: $('<strong>Test Content Modal!</strong>')
#   body: "This is a large modal! These options allow strings or jQueries."
#   footer: $('<button data-dismiss="modal">Close</button>')
# ===============================
# 
# Calling setupContentModal is not neccessary if you are fine
# with the default look of the contentModal. However, if you 
# want to add classes to the modal's innerds, I recommend you 
# make those adjustments within setupContentModal to avoid 
# potential conflicts if the modal is already open.
# 
# By default, calling showContentModal will close the content
# modal if it is already open. If for some reason you don't
# want that to happen, you can also pass force: false.
##
@setupContentModal = (setupFunc) ->
  $contentModal = $('#contentModal')
  wasOpen = false
  doSetup = ->
    $contentModal.off 'hidden.bs.modal', doSetup if wasOpen
    setupFunc($contentModal)

  if $contentModal.data('open')
    wasOpen = true
    $contentModal.on 'hidden.bs.modal', doSetup
  else
    doSetup()

@showContentModal = (options) ->
  options.force = true unless options.force is false
  $contentModal = $('#contentModal')

  wasOpen = false
  showIt = ->
    $contentModal.off 'hidden.bs.modal', showIt if wasOpen
    setSection = ($section, option) ->
      if typeof option is 'string'
        $section.text option
      else
        $section.append option

    setSection $('#contentTitle'),  options.title
    setSection $('#contentBody'),   options.body
    setSection $('#contentFooter'), options.footer

    $contentModal.modal 'show'
  
  if $contentModal.data('open')
    if options.force is true
      wasOpen = true
      $contentModal.on 'hidden.bs.modal', showIt
      $contentModal.modal 'hide'
  else
    showIt()

# Call this to invoke an error modal, sort of like alert
# body parameter is optional, title will default to "Error"
@errorModal = (titleOrBody, body) ->
  title = 
    if body
      titleOrBody
    else
      body = titleOrBody
      "Error"

  setupContentModal ($contentModal) ->
    $contentModal.find('.modal-content').addClass 'modal-content-error'
  showContentModal
    title: $("<string>#{title}</string>")
    body: body
    footer: $('<button class="btn btn-danger" data-dismiss="modal">OK</button>')

# Modal alternative to confirm() except you pass a function
# rather than call as a conditional.
# 
# With the callback, you can either pass a parameterless 
# function that will only be called when 'confirm' is clicked,
# or a single-parameter function where the parameter will
# be true or false depending on the user's response.
@confirmModal = (question, callback) ->
  $modal = $('#contentModal')

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

  setupContentModal ($contentModal) ->
    $contentModal.find('.modal-dialog').addClass 'modal-sm'
  showContentModal
    title: 'Confirm'
    body: question
    footer: $footer
