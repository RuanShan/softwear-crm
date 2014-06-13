@imprintMethodSelected = ($this) ->
  id = $this.val()
  $this.addClass 'editing-imprint'
  $imprintContainer = $this.parentsUntil('.imprint-container').parent()
  $printLocationContainer = $imprintContainer.find('.print-location-container')
  $printLocationContainer.addClass 'editing-imprint'

  ajax = $.ajax
    type: 'GET'
    url: "/configuration/imprint_methods/#{id}/print_locations"

  ajax.done (response) ->
    $response = $(response)
    $printLocationContainer.children().remove()
    $printLocationContainer.append $response
    $response.find('select').addClass 'editing-imprint'

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error, oh no!"

@printLocationSelected = ($this) ->
  id = $this.val()
  $this.addClass 'editing-imprint'

@updateImprints = ->
  console.log 'lol updating'

@addImprint = ->
  console.log 'lol adding'