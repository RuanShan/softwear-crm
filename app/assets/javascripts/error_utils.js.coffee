# Handy little module for ajax error handling!
# Doesn't actually do the ajaxing for you; just 
# adds and removes error content from the page.
@ErrorHandler = (resourceName, $form) ->
  handler = {}
  capitalize = (str) -> (str.charAt(0).toUpperCase() + str.substr(1)).replace('_id', '').replace('_', ' ')
  contains = (array, thing) -> 
    return true if entry == thing for entry in array
    false
  getParamName = (field) ->
    if resourceName is null
      field
    else
      "#{resourceName}[#{field}]"

  handler.errorFields = []

  handler.handleErrors = (errors, modal) ->
    handler.clear() if handler.errorFields.length > 0
    # Add modal
    $modal = null
    unless modal is null
      $modal = $(modal)
      $('body').children().last().after $modal
      $modal.on 'hidden.bs.modal', (e) -> $modal.remove()
    # Mark fields
    for field, fieldErrors of errors
      continue if fieldErrors.length == 0
      handler.errorFields.push(field)
      # Grab the input field element
      $field = $form.find("*[name='#{getParamName(field)}']")
      $field = $form.find("*[name='#{getParamName(field.replace('_id', ''))}']") if $field.length == 0
      if $field.length == 0
        console.log "Couldn't find field #{field}"
        continue
      # Create the error message div
      $errorMsgDiv = $ '<div/>',
        class: 'error'
        for:   getParamName(field)
      # Place it before the input field
      $field.before $errorMsgDiv
      # Wrap the input field to make it red
      $field.wrap $('<div/>', class: 'field_with_errors')
      # Populate error message div with messages
      for error in fieldErrors
        $errorMsgDiv.append $ '<p/>',
          class: 'text-danger'
          text:  "#{capitalize field} #{error}"
    # Show the modal
    $modal.modal 'show' unless $modal is null

  handler.clear = () ->
    for field in handler.errorFields
      $field = $form.find("*[name='#{getParamName(field)}']")
      $errorMsgDiv = $form.find(".error[for='#{getParamName(field)}']")
      $errorMsgDiv.remove()
      $field.unwrap() if $field.parent().attr('class') == 'field_with_errors'
    handler.errorFields = []

  return handler