@deleteJob = (jobId) ->
  $this = $(".delete-job-button[for='#{jobId}']")
  $this.attr 'disabled', 'disabled'
  setTimeout (-> $this.removeAttr 'disabled'), 30000

  ajax = $.ajax
    type: 'DELETE'
    url: "/jobs/#{jobId}"

  ajax.done (response) ->
    if response.result == 'success'
      $("#job-#{jobId}").fadeOut 1000
    else if response.result == 'failure'
      alert "Couldn't delete the job for some reason!"
    else
      console.log 'No idea what happened'

  ajax.fail (jqXHR, textStatus) ->
    alert "Something went wrong with the server and
        the job couldn't be deleted for some reason."

@refreshJob = (jobId) ->
  $job = $("#job-#{jobId}")
  if $job.length == 0
    console.log "Error! Couldn't find panel for job #{jobId}"
    return
  
  ajax = $.ajax
    type: 'GET'
    url: "/jobs/#{jobId}"

  ajax.done (response) ->
    console.log "Updated job #{jobId}"
    $job.replaceWith response
    refresh_inlines()

  ajax.fail (jqXHR, textStatus) ->
    alert "Failed to re-render job #{jobId}. Refresh the page to view changes."

$(window).load ->
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
        # The last child is the new button
        $('#jobs').children().last().before $newJob

        $('.scroll-y').scrollTo $('h3.job-title').last(),
          duration: 1000,
          offsetTop: 100

        # This should be called when .contenteditable fields are 
        # added through js
        refresh_inlines()
        registerAddLineItemButton($newJob.find '.add-line-item')

    ajax.fail (jqXHR, textStatus) ->
      alert "Something went wrong with the server and
             the new job couldn't be created."
