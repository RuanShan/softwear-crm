$(window).load ->
  $("#flashModal").modal "show"
  $("#errorsModal").modal "show"
  return

$(document).ready ->
  $('.format-phone').mask("999-999-9999")
  return

@after = (ms, func) ->
  setTimeout(func, ms)

@shine = (element, returnDefault) ->
  returnDefault = false if returnDefault is null
  $element = $(element)
  returnColor = 'default'
  returnColor = $element.css('background-color') unless returnDefault
  $element.css('background-color', '#99ffbb')
  $element.animate {backgroundColor: returnColor}, 1000, -> $element.css 'background-color', ''

$(window).load ->
  # TODO DEAL WITH DEFAULT VALUES AAAAH
