$(window).load ->
  $("#flashModal").modal "show"
  $("#errorsModal").modal "show"
  return

$(document).ready ->
  $(document).on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.removeable').hide()
    event.preventDefault()

  $(document).on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  $('.format-phone').mask("999-999-9999")
  return

@after = (ms, func) ->
  setTimeout(func, ms)

@shine = (element, returnDefault, duration) ->
  returnDefault = false if returnDefault is null
  $element = $(element)
  returnColor = 'default'
  returnColor = $element.css('background-color') unless returnDefault
  $element.css('background-color', '#99ffbb')
  $element.animate {backgroundColor: returnColor}, (duration or 1000), -> $element.css 'background-color', ''
