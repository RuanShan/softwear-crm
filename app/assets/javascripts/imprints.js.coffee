@imprintMethodSelected = ->
  $this = $(this)
  id = $this.val()

  $this.addClass 'editing-imprint' unless $this.closest('form').data('no-editing-class')
  # todo: using hardcoded name/number name
  $name_number_container = $this.parent().siblings("div.js-name-number-format-fields")
  if $this.children("option[value='#{ id }']").text() is 'Name/Number'
    $name_number_container.toggleClass("hidden", false)
    $name_number_container.children("input").toggleClass("editing-imprint", true)
  else
    $name_number_container.toggleClass("hidden", true)
    $name_number_container.children("input").toggleClass("editing-imprint", false)

  $imprintContainer = $this.closest('.imprint-container')
  $imprintEntry = $this.closest('.imprint-entry')
  imprintId = $imprintEntry.data('id')

  $printLocationContainer = $imprintContainer.find('.print-location-container')
  # $printLocationContainer.addClass 'editing-imprint'

  customName = $printLocationContainer.data('select_tag_name')
  if $this.val() == ''
    return

  ajax = $.ajax
    type: 'GET'
    url: Routes.imprint_method_print_locations_path(id)
    data: { name: customName or "imprint[#{imprintId}[print_location_id]]" }
    dataType: 'html'

  ajax.done (response) ->
    $response = $(response)
    $printLocationContainer.children().remove()
    $printLocationContainer.append $response
    printLocationSelected.call $response.find('select').get()

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error, oh no!"

@printLocationSelected = ->
  $this = $(this)
  $this.data('error-handler').clear() if $this.data 'handler'
  $this.addClass 'editing-imprint' unless $this.closest('form').data('no-editing-class')

@registerImprintEvents = ($parent) ->
  $parent.find('.js-delete-imprint-button').off 'click.imprint'
  $parent.find('.js-delete-imprint-button').on 'click.imprint', deleteImprint

  $parent.find('.js-print-location-select').off 'change.imprint'
  $parent.find('.js-print-location-select').on 'change.imprint', printLocationSelected

  $parent.find('.js-imprint-method-select').off 'change.imprint'
  $parent.find('.js-imprint-method-select').on 'change.imprint', imprintMethodSelected

  $parent.find('.js-imprint-has-name-number').off 'ifClicked.imprint'
  $parent.find('.js-imprint-has-name-number').on 'ifClicked.imprint', imprintHasNameNumberChecked

  $parent.find('.js-name-format-field').off 'change.imprint'
  $parent.find('.js-name-format-field').on 'change.imprint', printLocationSelected

  $parent.find('.js-number-format-field').off 'change.imprint'
  $parent.find('.js-number-format-field').on 'change.imprint', printLocationSelected


@deleteImprint = ->
  $btn = $(this)
  $container    = $btn.parentsUntil('.imprint-entry').parent()
  imprintId     = $container.data('id')

  if imprintId < 0
    $container.fadeOut thenRemove $container
  else
    ajax = $.ajax
      type: 'DELETE'
      url: Routes.imprint_path(imprintId)
      dataType: 'script'

    ajax.done eval

  false

@imprintHasNameNumberChecked = ->
  # This is for some reason fired before the new check state is assigned...
  checked = !this.checked

  $this = $(this)

  if typeof $this.data('original-value') is 'undefined' or $this.data('original-value') is null
    # console.log 'ok first time set'
    $this.data('original-value', this.checked)

  method = if $this.data('original-value') == checked then 'removeClass' else 'addClass'
  $this.parentsUntil('.checkbox-container').parent()[method] 'editing-imprint'

  method = if checked then 'fadeIn' else 'fadeOut'
  $this.closest('.checkbox-container').siblings('.js-imprint-name-number-fields')[method]()

@nameNumberChanged = ->
  $(this).addClass 'editing-imprint'

$ ->
  $(document).mouseup (e) ->
    unless $(e.target).is '.update-imprints' or $(e.target).closest('.imprint-container').length > 0
      $('.update-imprints').click() if $('.editing-imprint').length isnt 0

