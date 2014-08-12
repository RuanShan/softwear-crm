#TODO look into js response in controller to trim this??
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

  # TODO TUESDAY
  # Well... For one, this ajax replacement of
  # imprint_methods/print_locations_select does not pass the :name option
  # parameter, meaning it defaults to just 'imprint_method', meaning
  # nothing gets sent to the server. :( so we need the imprint id.
  # 
  # After that is taken care of, we must deal with visually handling the
  # creation (or failure to do so) of new imprints within
  # imprints/update.js.erb. This shouldn't be much of a hardship.

  ajax.done (response) ->
    $response = $(response)
    $printLocationContainer.children().remove()
    $printLocationContainer.append $response
    printLocationSelected.call $response.find('select').get()

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error, oh no!"

@printLocationSelected = ->
  $this = $(this)
  $this.data('handler').clear() if $this.data 'handler'
  $this.addClass 'editing-imprint'

# TODO js response Nigel - I think this is handled in js now
@updateImprints = ($btn) ->
  $btn.attr 'disabled', 'disabled'
  setTimeout (-> $btn.removeAttr 'disabled'), 1000

  $('.editing-imprint').each ->
    $this = $(this)
    if $this.attr('name') is 'print_location'
      $container = $this.parentsUntil('.imprint-entry').parent()
      $imprintMethod = $container.find('select[name="imprint_method"]')
      imprintId = $container.data('id')

      $this.data('handler', ErrorHandler(null, $container.find('.print-location-container'))) unless $this.data('handler')

      ajaxDone = (response) ->
        if response.result is 'success'
          unless response.imprint_id is null
            $container.attr 'data-id', response.imprint_id
          $this.removeClass 'editing-imprint'
          $imprintMethod.removeClass 'editing-imprint'
          shine $this, true
          shine $imprintMethod, true
        else
          console.log "FAILED"
          $this.data('handler').handleErrors response.errors, null

      ajaxFail = (jqXHR, textStatus) ->
        alert "Internal server error, can't do anything."

      if imprintId is -1
        # create
        jobId = $container.parentsUntil('.job-container').parent().data('id')
        ajax = $.ajax
          type: 'POST'
          url: Routes.job_imprints_path(jobId)
          data: { "imprint[print_location_id]": $this.val(), "imprint[job_id]": jobId }
          dataType: 'json'
        ajax.done ajaxDone
        ajax.fail ajaxFail
      else
        # update
        ajax = $.ajax
          type: 'PUT'
          url: Routes.imprint_path(imprintId)
          data: { "imprint[print_location_id]": $this.val(), "imprint[job_id]": jobId }
          dataType: 'json'
        ajax.done ajaxDone
        ajax.fail ajaxFail

  after 1000, updateOrderTimeline

@registerImprintEvents = ($parent) ->
  $parent.find('.js-delete-imprint-button').click deleteImprint
  $parent.find('.js-print-location-select').change printLocationSelected
  $parent.find('.js-imprint-method-select').change imprintMethodSelected

# TODO js response Nigel
@addImprint = ($this, jobId) ->
  ajax = $.ajax
    type: 'GET'
    url: Routes.new_job_imprint_path(jobId)
    dataType: 'html'

  ajax.done (response) ->
    $response = $(response)
    $response.find('select').addClass 'editing-imprint'
    $("#job-#{jobId}").find('.imprints-container').append $response
    registerImprintEvents $response

@deleteImprint = ->
  $btn = $(this)
  $container    = $btn.parentsUntil('.imprint-entry').parent()
  imprintId     = $container.data('id')

  if imprintId is -1
    $container.fadeOut thenRemove $container
  else
    ajax = $.ajax
      type: 'DELETE'
      url: Routes.imprint_path(imprintId)
      dataType: 'script'
    
    ajax.done eval

  false
