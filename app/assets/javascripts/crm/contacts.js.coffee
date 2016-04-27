@initializeContactSearchResults = ->
  $("input[name='contact_select']").change ->
    if(this.checked)
      $('#search_contact_form_id').val($(this).val())
      $('#search_contact_form_id').attr('disabled', false)

@toggleNewContactContent = (enable) ->
  if enable
    $('#new_contact_content').show()
    $('#new_contact_content input').prop('disabled', false)
  else
    $('#new_contact_content').hide()
    $('#new_contact_content input').prop('disabled', true)

@toggleEditContactContent = (enable) ->
  if enable
    $('#edit_contact_content').show()
    $('#edit_contact_content input').prop('disabled', false)
  else
    $('#edit_contact_content').hide()
    $('#edit_contact_content input').prop('disabled', true)

@toggleSearchContactContent = (enable) ->
  if enable
    $('#search_contact_content').show()
    $('#search_contact_content input').prop('disabled', false)
  else
    $('#search_contact_content').hide()
    $('#search_contact_content input').prop('disabled', true)

@contactSearch = ->
  event.preventDefault()
  $.ajax Routes.search_path({format: 'js'}),
    type: 'GET'
    dataType: 'script'
    data: {'search[crm::contact][fulltext]': $('#contact_search_terms').val() }
    error: (jqXHR, textStatus, errorThrown) ->
      $('body').append "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      $('body').append "Successful AJAX call: #{data}"
  return

$ ->
  $('.email-primary').change ->
    if this.checked
      $(".email-primary:not(#"+$(this).id()+")").removeAttr('checked')

  $('.phone-primary').change ->
    if this.checked
      $(".phone-primary:not(#"+$(this).id()+")").removeAttr('checked')

  $('#contact_search').click (event) ->
    contactSearch()

  $('#contact_search_terms').on 'keypress', (e) ->
    event.preventDefault()
    if e.keyCode == 13
      contactSearch()

  $('#create_new_contact_link > a').click (event) ->
    $('#search_contact_form_id').prop('disabled', false)
    $('#new_contact_content input').prop('disabled', false)
    $('#create_new_contact_link').hide()
    $('#search_existing_contacts_link').show()

    $('#existing_contact_content').hide()
    $('#new_contact_content').show()
    $('#search_contact_content').hide()
    $('#edit_contact_content').hide()

  $('#search_existing_contacts_link > a').click (event) ->
    $('#search_existing_contacts_link').hide()
    $('#create_new_contact_link').show()

    $('#existing_contact_content').hide()
    toggleSearchContactContent(true)
    toggleNewContactContent(false)
    toggleEditContactContent(false)

  $('#edit_current_contact_link > a').click (event) ->
    $('#create_new_contact_link').hide()
    $('#edit_current_contact_link').hide()
    $('#search_existing_contacts_link').hide()
    $('#cancel_contact_changes_link').show()

    $('#existing_contact_content').hide()
    $('#search_contact_content').hide()
    toggleNewContactContent(false)
    toggleEditContactContent(true)

  $('#change_contact_link > a').click (event) ->
    $('#create_new_contact_link').hide()
    $('#edit_current_contact_link').hide()
    $('#search_existing_contacts_link').show()
    $('#change_contact_link').hide()
    $('#cancel_contact_changes_link').show()

    $('#existing_contact_content').hide()
    $('#search_contact_content').hide()
    toggleNewContactContent(true)
    toggleEditContactContent(false)

  $('#cancel_contact_changes_link > a').click (event) ->
    $('#create_new_contact_link').hide()
    $('#edit_current_contact_link').show()
    $('#search_existing_contacts_link').hide()
    $('#change_contact_link').show()
    $('#cancel_contact_changes_link').hide()

    $('#existing_contact_content').show()
    $('#search_contact_content').hide()
    toggleNewContactContent(false)
    toggleEditContactContent(false)