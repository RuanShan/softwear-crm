@imprintMethodSelected = ->
  $this = $(this)
  id = $this.val()
  
  $this.addClass 'editing-imprint'
  # todo: using hardcoded name/number name
  if $this.children("option[value='#{ id }']").text() is 'Name/Number'
    $this.parent().siblings("div.js-name-number-format-fields").toggleClass("hidden", false)
  else
    $this.parent().siblings("div.js-name-number-format-fields").toggleClass("hidden", true)
  $imprintContainer = $this.parentsUntil('.imprint-container').parent()
  
  $imprintEntry = $this.parentsUntil('.imprint-entry').parent()
  imprintId = $imprintEntry.data('id')

  $printLocationContainer = $imprintContainer.find('.print-location-container')
  # $printLocationContainer.addClass 'editing-imprint'

  ajax = $.ajax
    type: 'GET'
    url: Routes.imprint_method_print_locations_path(id)
    data: { name: "imprint[#{imprintId}[print_location_id]]" }
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
  $this.addClass 'editing-imprint'

@registerImprintEvents = ($parent) ->
  $parent.find('.js-delete-imprint-button').click deleteImprint
  $parent.find('.js-print-location-select').change printLocationSelected
  $parent.find('.js-imprint-method-select').change imprintMethodSelected
  $parent.find('.js-imprint-has-name-number').on 'ifClicked', imprintHasNameNumberChecked
  $parent.find('.js-imprint-name-number').change nameNumberChanged

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
