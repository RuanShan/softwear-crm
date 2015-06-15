jQuery ->

  $("#email_template_plaintext_body").markItUp(html_editor_settings)

  $(".note-editor").markItUp(html_editor_settings)

  $("#email_plaintext_body").markItUp(html_editor_settings)

  $("#email_body").markItUp(html_editor_settings)

@prepareFreshdeskSelect = ->
  $(".freshdesk-select").click ->
    SelectText('freshdesk-email-temp')
