$.fn.modal.Constructor.prototype.enforceFocus = ->

$(window).load ->
  $("#flashModal").modal "show"
  $("#errorsModal").modal "show"
  $("#dock").zIndex(1000)

@initializeSelect2 = ->
  $('select.select2').each ->
    placeholder = $(this).data('placeholder')
    if placeholder
      resetVal = $(this).data('isblank')

      $(this).select2
        allowClear: true
        placeholder: placeholder

      $(this).val('').trigger('change') if resetVal
    else
      $(this).select2()

  $('.select2-tags').select2
    allowClear: true
    tags: true
    tokenSeparators: [','],
    placeholder: $(this).data('placeholder')

  $('.ink-color-select2').each ->
    self = $(this)

    self.select2
      allowClear: true
      placeholder: $(this).data('placeholder')
      tags: true

    self.on 'select2:select', (e) ->
      data = self.select2 'data'
      self.children().each ->
        if $(this).val() is e.params.data.id
          $(this).text "Custom (#{e.params.data.text})"

      # self.trigger 'change'

@initializeEditable = ->
  $('.editable').each ->
    $(this).editable
      mode: $(this).data('mode') or 'popup'

$(document).ready ->
  $(document).on 'submit', 'form', (e) ->
    timeout = null
    buttons = $(this).find('button[type=submit],input[type=submit]')
    buttons.prop('disabled', true)

    reEnable = ->
      buttons.prop('disabled', false)
      $('[data-remote]').off 'ajax:success', reEnable
      clearTimeout(timeout) if timeout

    timeout = setTimeout reEnable, 10000
    $('[data-remote]').on 'ajax:success', reEnable

  $(document).on 'click', '.kill-closest', (e) ->
    $(this).closest($(this).data('target')).remove()
    e.preventDefault()

  $(document).on 'click', '.insert-before', (e) ->
    content = $(this).data('content')
    $(this).before(content)
    e.preventDefault()

  $(document).on 'click', '.js-remove-fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.js-removeable').hide()
    event.preventDefault()

  $(document).on 'click', '.js-add-fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    $(this).closest('.form-group').find('.select2').select2()
    event.preventDefault()

  $('.format-phone').mask("999-999-9999")
  initializeSelect2()

  $("#easyWizard").easyWizard
    buttonsClass: "btn btn-default"
    submitButtonClass: "btn btn-primary"

  initializeEditable()


$(document).ajaxStart ->
  $('#js-ajax-loading').show()

$(document).ajaxStop ->
  $('#js-ajax-loading').hide()

@after = (ms, func) ->
  setTimeout(func, ms)

@disableFor = (element, ms) ->
  $(element).attr 'disabled', 'disabled'
  after ms, -> $(element).removeAttr 'disabled'

@initializeDateTimePicker = ->
  $(".js-datetimepicker").datetimepicker()
  $(".js-datetimepicker input[type='text']").datetimepicker()

@setPendingSelect = ->
  $(".js-pending-select").hide()
  $(".js-pending-select").val "Pending"

@setSubmitTimeout = ->
  $("input[type=submit]").click ->
    $add = $(this)
    $(this).parents("form").submit()
    $add.attr 'disabled', 'disabled'
    setTimeout (-> $add.removeAttr 'disabled'), 5000

@shine = (element, returnDefault, duration, color) ->
  returnDefault = false if returnDefault is null
  $element = $(element)
  returnColor = 'default'
  returnColor = $element.css('background-color') unless returnDefault
  $element.css('background-color', (color or '#99ffbb'))
  $element.animate {backgroundColor: returnColor}, (duration or 1000), -> $element.css 'background-color', ''

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
