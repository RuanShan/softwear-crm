# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#email-template-select').change ->
    if $(this).val() != ''
      $.ajax
        method: 'GET'
        url: "/" + $(this).attr('data-model') + "s/" + $(this).attr('data-record-id') + '/emails/new'
        data: email_template_id: $(this).val()
        dataType: 'script'
      return
  return

