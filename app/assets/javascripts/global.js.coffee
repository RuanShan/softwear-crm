$(window).load ->
  $("#flashModal").modal "show"
  $("#errorsModal").modal "show"
  $("#dock").zIndex(1000)

$(document).ready ->
  $(document).on 'click', '.js-remove-fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.js-removeable').hide()
    event.preventDefault()

  $(document).on 'click', '.js-add-fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  $('.format-phone').mask("999-999-9999")

  $("#easyWizard").easyWizard
    buttonsClass: "btn btn-default"
    submitButtonClass: "btn btn-primary"

  $('.editable').editable()


$(document).ajaxStart(->
  $('#js-ajax-loading').modal('show'))

$(document).ajaxStop(->
  $('#js-ajax-loading').modal('hide'))

@after = (ms, func) ->
  setTimeout(func, ms)

@disableFor = (element, ms) ->
  $(element).attr 'disabled', 'disabled'
  after ms, -> $(element).removeAttr 'disabled'

@initializeDateTimePicker = ->
  $(".js-datetimepicker").datetimepicker()
  $(".js-datetimepicker input[type='text']").datetimepicker()

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
      ['view', ['fullscreen', 'codeview']],
    ]

  $(".summernote").code "" if $(".note-editable").html() is "<p><br></p>"

@setPendingSelect = ->
  $(".js-pending-select").hide()
  $(".js-pending-select").val "Pending"

@setSubmitTimeout = ->
  $("input[type=submit]").click ->
    $add = $(this)
    $(this).parents("form").submit()
    $add.attr 'disabled', 'disabled'
    setTimeout (-> $add.removeAttr 'disabled'), 5000

@shine = (element, returnDefault, duration) ->
  returnDefault = false if returnDefault is null
  $element = $(element)
  returnColor = 'default'
  returnColor = $element.css('background-color') unless returnDefault
  $element.css('background-color', '#99ffbb')
  $element.animate {backgroundColor: returnColor}, (duration or 1000), -> $element.css 'background-color', ''

@summernoteSubmit = ->
  $(".summernote").closest("form").submit ->
    $(".summernote").val $(".summernote").code()

@styleCheckboxes = ->
  $("input").iCheck
    checkboxClass: "icheckbox_minimal-grey"
    radioClass: "iradio_minimal-grey"
    increaseArea: "20%"

@disableFor = (element, ms) ->
  $(element).attr 'disabled', 'disabled'
  after ms, -> $(element).removeAttr 'disabled'

@thenRemove = ($element) ->
  -> $element.remove()
