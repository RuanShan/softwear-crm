# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#myWizard").easyWizard
    buttonsClass: "btn btn-default"
    submitButtonClass: "btn btn-primary"

  return

$(window).load ->
  # Edit can't redirect, meaning it can't supply an anchor, so
  # we use data from the error modal to know which tab to switch 
  # to when the user submits bad data to an edit
  if $('#errorsModal').length > 0
    switch $('#errorsModal').attr 'resource'
      when 'order' then window.location.hash = 'details'

  $("a[data-toggle='tab']").click ->
    window.location.hash = $(this).attr 'href'

  if window.location.hash != ''
    dashIndex = window.location.hash.indexOf '-'
    target = window.location.hash
    data = null
    if dashIndex > 0
      data = parseInt target.substr dashIndex+1
      target = target.substring 0, dashIndex

    tab = $("a[href='#{target}']")
    tab.trigger $.Event('click')

    if data && data != NaN
      after 500, ->
        if target == '#jobs'
          $('.scroll-y').scrollTo $("#job-#{data}").find('.job-title'),
            duration: 1000,
            offsetTop: 100

  $('#datetimepicker1').datetimepicker()

