# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#myWizard").easyWizard
    buttonsClass: "btn btn-default"
    submitButtonClass: "btn btn-primary"

  return

$(window).load ->
  $("a[data-toggle='tab']").click ->
    window.location.hash = $(this).attr 'href'
  if window.location.hash != ''
    tab = $("a[href='#{window.location.hash}']")
    tab.trigger $.Event('click')
