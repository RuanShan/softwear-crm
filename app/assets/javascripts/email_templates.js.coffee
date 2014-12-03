jQuery ->
  $(document).on('change', '#email_template_quote_id', ->
    if $(this).val() is ''
      $("#associated_record_fields").hide()
    else
      $("#associated_record_fields").show()
  )
#  $(document).on('change', '#email_template_associated_model', ->
#    $.ajax '/configuration/email_templates/fetch_table_attributes/' + $(this).val(),
#      type: 'GET'
#      error: (jqXHR, textStatus, errorThrown) ->
#        console.log("Error fetching table attributes: " + textStatus)
#  )

  $(document).on('click', '#preview_button', ->
    url_array = document.URL.split('/')
    id = url_array[url_array.length - 2]
    jQuery.ajax '/configuration/email_templates/' + id + '/preview_body',
      type: 'GET'
      data: { body: $('#email_template_body').val() }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("Error fetching email body: " + textStatus)
  )
