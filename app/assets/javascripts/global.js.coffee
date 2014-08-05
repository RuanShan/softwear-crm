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

$(document).ajaxStart(->
  $('#ajax_loading').modal('show')
  console.log 'Ajax started')
$(document).ajaxStop(->
  $('#ajax_loading').modal('hide')
  console.log 'Ajax stopped')

@after = (ms, func) ->
  setTimeout(func, ms)

@shine = (element, returnDefault, duration) ->
  returnDefault = false if returnDefault is null
  $element = $(element)
  returnColor = 'default'
  returnColor = $element.css('background-color') unless returnDefault
  $element.css('background-color', '#99ffbb')
  $element.animate {backgroundColor: returnColor}, (duration or 1000), -> $element.css 'background-color', ''

@setSubmitTimeout = ->
  $("input[type=submit]").click ->
    $add = $(this)
    $(this).parents("form").submit()
    $add.attr 'disabled', 'disabled'
    setTimeout (-> $add.removeAttr 'disabled'), 5000

@summernoteSubmit = ->
  $(".summernote").closest("form").submit ->
    $(".summernote").val $(".summernote").code()

@initializeDateTimePicker = ->
  #TODO change everything to use this, call class .js-datetimepicker
  $(".date").datetimepicker()

@styleCheckboxes = ->
  $("input").iCheck
    checkboxClass: "icheckbox_minimal-grey"
    radioClass: "iradio_minimal-grey"
    increaseArea: "20%"

@initializeSummernote = ->
  $(".summernote").summernote
    height: 300
    toolbar:[
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
      ['fontsize', ['fontsize']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['height', ['height']],
      ['table', ['table']],
      ['view', ['fullscreen', 'codeview']]
    ],

  $(".summernote").code "" if $(".note-editable").html() is "<p><br></p>"
  $(".summernote").val ""