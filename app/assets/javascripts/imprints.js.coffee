#TODO look into js response in controller to trim this??
@imprintMethodSelected = ($this) ->
  id = $this.val()
  $this.addClass 'editing-imprint'
  $imprintContainer = $this.parentsUntil('.imprint-container').parent()
  $printLocationContainer = $imprintContainer.find('.print-location-container')
  $printLocationContainer.addClass 'editing-imprint'

  ajax = $.ajax
    type: 'GET'
    url: Routes.imprint_method_print_locations_path(id)
    dataType: 'html'

  ajax.done (response) ->
    $response = $(response)
    $printLocationContainer.children().remove()
    $printLocationContainer.append $response
    printLocationSelected($response.find('select'))

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error, oh no!"

@printLocationSelected = ($this) ->
  $this.data('handler').clear() if $this.data 'handler'
  $this.addClass 'editing-imprint'

# TODO js response Nigel
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

# TODO js response Nigel
@deleteImprint = ($btn, jobId) ->
  console.log "job id: #{jobId} imprintId: #{imprintId}"
  $jobContainer = $btn.parentsUntil('.job-container').parent()
  if $jobContainer.data('id') is jobId
    $container = $btn.parentsUntil('.imprint-entry').parent()
    imprintId = $container.data('id')
    killContainer = ->
      $container.fadeOut -> $container.remove() 

    if imprintId is -1
      killContainer()
    else
      $btn.attr 'disabled', 'disabled'
      setTimeout (-> $btn.removeAttr 'disabled'), 10000

      ajax = $.ajax
        type: 'DELETE'
        url: Routes.imprint_path(imprintId)
        dataType: 'json'

      ajax.done (response) ->
        if response.result is 'success'
          killContainer()
          updateOrderTimeline()
        else
          alert 'Something strange happened!'
      ajax.fail (jqXHR, errorText) ->
        if jqXHR.statusCode is 404
          killContainer()
        else
          errorModal "Either the internet is down, or there was an error in the server."