# TODO js response
@deleteJob = ($this, jobId) ->
  $this.attr 'disabled', 'disabled'
  setTimeout (-> $this.removeAttr 'disabled'), 1000
  confirmModal 'Are you sure?', ->

    ajax = $.ajax
      type: 'DELETE'
      url: Routes.job_path(jobId)
      dataType: 'json'

    ajax.done (response) ->
      if response.result == 'success'
        $("#job-#{jobId}").fadeOut 500, updateOrderTimeline
      else if response.result == 'failure'
        errorModal response.error
        $this.removeAttr 'disabled'
      else
        console.log 'No idea what happened'

    ajax.fail (jqXHR, textStatus) ->
      alert "Something went wrong with the server and
          the job couldn't be deleted for some reason."

#TODO js response
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

#TODO custom controller action
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
  # TODO replace inline job events with logic in here if Ricky insists

# TODO Nigel, js response it up
$(window).load ->
  registerJobEvents($('body'))

  $('#new-job-button').click ->
    $this = $(this)
    $this.attr 'disabled', 'disabled'
    setTimeout (-> $this.removeAttr 'disabled'), 1000

    ajax = $.ajax
      type: 'POST'
      url: "/orders/#{$this.attr 'data-order-id'}/jobs"

    ajax.done (response) ->
      if typeof response is 'object'
        msg = "Error creating new job!:\n"
        msg += "#{error}\n" for error in response.errors
        alert msg
      else
        $newJob = $(response)
        # The last child is the new button (so append won't do it)
        $('#jobs').children().last().before $newJob

        $('.scroll-y').scrollTo $('h3.job-title').last(),
          duration: 1000,
          offsetTop: 100

        # This should be called when jobs are added through js
        registerJobEvents($newJob)

        updateOrderTimeline()

    ajax.fail (jqXHR, textStatus) ->
      alert "Something went wrong with the server and
             the new job couldn't be created."
