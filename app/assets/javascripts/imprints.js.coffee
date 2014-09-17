@imprintMethodSelected = ->
  $this = $(this)
  id = $this.val()
  
  $this.addClass 'editing-imprint'
  $imprintContainer = $this.parentsUntil('.imprint-container').parent()
  
  $imprintEntry = $this.parentsUntil('.imprint-entry').parent()
  imprintId = $imprintEntry.data('id')

  $printLocationContainer = $imprintContainer.find('.print-location-container')
  $printLocationContainer.addClass 'editing-imprint'

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

$ ->
  $('.js-imprint-has-name-number').on 'ifClicked', ->
    # This is for some reason fired before the new check state is assigned...
    checked = !this.checked
    $(this).parentsUntil('.checkbox-container').parent().addClass 'editing-imprint'

    # TODO spawn fields
