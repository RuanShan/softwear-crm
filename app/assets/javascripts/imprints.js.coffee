@nameNumberChecked = ->
  $this = $(this)
  $name_number_container = $this.closest('.imprint-container').find(".js-name-number-format-fields")

  if this.checked
    $name_number_container.toggleClass('hidden', false)
    $name_number_container.children("input").toggleClass("editing-imprint", true)
  else
    $name_number_container.toggleClass('hidden', true)

@imprintMethodSelected = ->
  $this = $(this)
  id = $this.val()

  $this.addClass 'editing-imprint' unless $this.closest('form').data('no-editing-class')
  $name_number_container = $this.closest('.imprint-container').find(".js-name-number-format-fields")
  $name_number_checkbox = $this.closest('.imprint-container').find('.name-number-checkbox')

  if $this.siblings(".name-number-imprint-method-id[data-id=#{id}]").length
    $name_number_checkbox.removeClass  "hidden", false
    if $name_number_checkbox.find('input[type=checkbox]')[0].checked
      $name_number_container.toggleClass "hidden", false
  else
    $name_number_container.toggleClass "hidden", true
    $name_number_container.children("input").toggleClass("editing-imprint", false)
    if $name_number_checkbox.find('input[type=checkbox]')[0].checked
      $name_number_checkbox.find('input[type=checkbox]')[0].checked = false
    $name_number_checkbox.toggleClass  "hidden", true

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
    data: { name: customName or "imprint[#{imprintId}][print_location_id]", imprint_id: imprintId }
    dataType: 'html'

  ajax.done (response) ->
    $response = $(response)
    $printLocationContainer.children().remove()
    $printLocationContainer.append $response
    $selects = $response.find('select')
    imprintSelectChanged.call $selects
    $selects.select2()

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error, oh no!"

@imprintFieldChanged = ->
  $this = $(this)
  $this.data('error-handler').clear() if $this.data 'handler'
  $this.addClass 'editing-imprint' unless $this.closest('form').data('no-editing-class')

@imprintSelectChanged = ->
  $this = $(this)
  $this.data('error-handler').clear() if $this.data 'handler'

  unless $this.closest('form').data('no-editing-class')
    $this.addClass 'editing-imprint'
    $this.next('span.select2-container').find('.select2-selection__rendered').addClass 'editing-imprint'

@registerImprintEvents = ($parent) ->
  $parent.find('.js-delete-imprint-button').off 'click.imprint'
  $parent.find('.js-delete-imprint-button').on 'click.imprint', deleteImprint

  $parent.find('.js-print-location-select').off 'change.imprint'
  $parent.find('.js-print-location-select').on 'change.imprint', imprintSelectChanged

  $parent.find('.js-select-option-value').off 'change.imprint'
  $parent.find('.js-select-option-value').on 'change.imprint', imprintSelectChanged

  $parent.find('.js-imprint-method-select').off 'change.imprint'
  $parent.find('.js-imprint-method-select').on 'change.imprint', imprintMethodSelected

  $parent.find('.js-name-format-field').off 'change.imprint'
  $parent.find('.js-name-format-field').on 'change.imprint', imprintFieldChanged

  $parent.find('.js-number-format-field').off 'change.imprint'
  $parent.find('.js-number-format-field').on 'change.imprint', imprintFieldChanged

  $parent.find('.js-imprint-description').off 'change.imprint'
  $parent.find('.js-imprint-description').on 'change.imprint', imprintFieldChanged

  setTimeout (->
    $parent.find('.js-imprint-is-name-number').off 'change.imprint'
    $parent.find('.js-imprint-is-name-number').on 'change.imprint', nameNumberChecked
    $parent.find('.js-imprint-is-name-number').off 'ifChecked.imprint'
    $parent.find('.js-imprint-is-name-number').on 'ifChecked.imprint', nameNumberChecked
    $parent.find('.js-imprint-is-name-number').off 'ifUnchecked.imprint'
    $parent.find('.js-imprint-is-name-number').on 'ifUnchecked.imprint', nameNumberChecked
  ), 1

  styleCheckboxes $parent.find('input[type=checkbox]')

  $parent.find('select').select2()


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
    unless $(e.target).is('.update-imprints') or $(e.target).closest('.imprint-container').length > 0 or $(e.target).hasClass('select2-selection__rendered') or $(e.target).hasClass('select2-results__option')
      $('.update-imprints').click() if $('.editing-imprint').length isnt 0
