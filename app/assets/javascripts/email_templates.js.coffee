jQuery ->

  $("#email_template_plaintext_body").markItUp(mySettings)

  $(".note-editor").markItUp(mySettings)

  $("#email_plaintext_body").markItUp(mySettings)

  $("#email_body").markItUp(mySettings)

@prepareFreshdeskSelect = ->
  $(".freshdesk-select").click ->
    SelectText('freshdesk-email-temp')
