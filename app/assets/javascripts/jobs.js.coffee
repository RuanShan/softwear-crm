@refreshJob = (jobId) ->
  $job = $("#job-#{jobId}")
  if $job.length == 0
    console.log "Error! Couldn't find panel for job #{jobId}"
    return
  
  ajax = $.ajax
    type: 'GET'
    url: Routes.job_path(jobId)
    dataType: 'json'

  ajax.done (response) ->
    $job.replaceWith response.content
    refresh_inlines()
    registerJobEvents $("#job-#{jobId}")
    console.log "Updated job #{jobId}"
    updateOrderTimeline()

  ajax.fail (jqXHR, textStatus) ->
    alert "Failed to re-render job #{jobId}. Refresh the page to view changes."

# TODO For now, leaving job collapse as coffeescript.
# May be unable to mix bootstrap collapse toggle with
# Rails remote: true, at which point we are stuck with
# listening for collapse events anyways.
jobCollapse = (id, collapsed) ->
  ajax = $.ajax
    type: 'PUT'
    url: Routes.job_path(id)
    data: { 'job[collapsed]': collapsed.toString() }
    dataType: 'json'

  ajax.done (response) ->
    unless response.result is 'success'
      errorModal "The job couldn't be saved!"

  ajax.fail (jqXHR, textStatus) ->
    errorModal 'Either the server is messed up, or your internet is down!'

@onJobCollapseShow = ->
  jobCollapse $(this).data('job-id'), true

@onJobCollapseHide = ->
  jobCollapse $(this).data('job-id'), false

@registerJobEvents = ($c) ->
  refresh_inlines()
  $jobCollapse = $c.find('.job-collapse')

  $jobCollapse.off 'show.bs.collapse', onJobCollapseShow
  $jobCollapse.off 'hide.bs.collapse', onJobCollapseHide

  $jobCollapse.on 'show.bs.collapse', onJobCollapseShow
  $jobCollapse.on 'hide.bs.collapse', onJobCollapseHide

  registerImprintEvents $c

$(window).load ->
  registerJobEvents($('body'))

#jQuery ->
#  $('.chosen-select').chosen
#    width: '200px'
