Dropzone.options.jsPackingSlipForm =
  paramName: 'packing_slips'
  maxFilesize: 1#MB
  uploadMultiple: true
  successmultiple: (file, response) ->
    for entry in response
      container = $(entry.container)
      $('#js-packing-slip-info-zone').append container
      container.find('.info').append entry.info

$.fn.modal.Constructor.prototype.enforceFocus = ->

$(window).load ->
  $("#flashModal").modal "show"
  $("#errorsModal").modal "show"
  $("#dock").zIndex(1000)
  $(document).on 'select2:open', ->
    $('.select2-dropdown').css 'z-index', '9999999'

  initializeDateTimePicker()

@initializeSelect2 = (opts) ->
  scope = $('body')
  if opts isnt undefined and opts.scope
    scope = opts.scope

  scope.find('select.select2').each ->
    placeholder = $(this).data('placeholder')
    if placeholder
      resetVal = $(this).data('isblank')

      $(this).select2
        allowClear: true
        placeholder: placeholder

      $(this).val('').trigger('change') if resetVal
    else
      $(this).select2()

  scope.find('.select2-tags').select2
    allowClear: true
    tags: true
    tokenSeparators: [','],
    placeholder: $(this).data('placeholder')

  scope.find('.ink-color-select2').each ->
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
  $('a.print-page').click ->
    window.print()

  $('.colorpicker').minicolors
    theme:      'bootstrap',
    letterCase: 'uppercase'

  $(document).on 'nested:fieldAdded', (e)-> initializeSelect2(e.field)

  $(document).on 'click', 'button[type=submit],input[type=submit],a[data-remote]', (e) ->
    e.preventDefault() if $(this).closest('[data-fading-out]').length isnt 0

  disableButtons = (e) ->
    timeout = null
    buttons = $(this).find('button[type=submit],input[type=submit],a[data-remote]')
    buttons.prop 'disabled', true

    reEnable = ->
      buttons.prop 'disabled', false
      $('[data-remote]').off 'ajax:success', reEnable
      clearTimeout(timeout) if timeout

    timeout = setTimeout reEnable, 10000
    $('[data-remote]').on 'ajax:success', reEnable

  $(document).on 'submit', 'form', disableButtons
  $(document).on 'ajax:start', '[data-remote]', disableButtons

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

  $(document).on 'click', '.hide-loading-spinner', (event) ->
    $('.hide-loading-spinner').on 'click', $('#loading').fadeOut("slow")
    event.preventDefault()

  $('.remote-nav-tab').click (e) ->
    $this = $(this)
    return if $this.data('loaded')

    $.ajax
      url:       $this.data('url')
      method:    'get'
      dataType: 'script'

    $this.data('loaded', true)


$(document).ajaxStart ->
  unless window.noSpinner
    $('#loading').fadeIn(100)

$(document).ajaxStop ->
  unless window.noSpinner
    $('#loading').fadeOut(100)

@after = (ms, func) ->
  setTimeout(func, ms)

@disableFor = (element, ms) ->
  $(element).attr 'disabled', 'disabled'
  after ms, -> $(element).removeAttr 'disabled'

now = new Date()
initial = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 17, 0)
$.fn.datetimepicker.defaults.defaultDate = initial

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

@styleCheckboxes = (element) ->
  (element or $("input")).iCheck
    checkboxClass: "icheckbox_minimal-grey"
    radioClass: "iradio_minimal-grey"
    increaseArea: "20%"

@disableFor = (element, ms) ->
  $(element).attr 'disabled', 'disabled'
  after ms, -> $(element).removeAttr 'disabled'

@thenRemove = ($element) ->
  $element.prop 'data-fading-out', true
  -> $element.remove()

@initializeAll = ->
  initializeEditable()
  initializeDateTimePicker()
  initializeSelect2()
  styleCheckboxes()
