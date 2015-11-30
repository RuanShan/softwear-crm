@initializeJobsChosen = ->
  ###
  $("#artwork_request_job_ids").select2
    placeholder: "Select all jobs for this request"
    width: "400px"
  ###

$(document).ready ->
  $(document).on "change", "#artwork_request_imprint_ids", ->
    if $(this).find(":selected").attr("value")
      ajax = $.ajax
        url: Routes.imprint_ink_colors_path()
        dataType: "script"
        data:
          ids: $(this).val()
      ajax.done ->
        styleCheckboxes()

  $("a.reject-artwork-request").click (event) ->
    event.preventDefault()
    $("div.reject-artwork-request[data-id='"+$(this).data('id')+"']").show()
    $("h3[data-id='"+$(this).data('id')+"']").text($(this).text())
    form = $("form.reject-artwork-request-form[data-id='"+$(this).data('id')+"']")
    form.find(".transition").val($(this).data('transition'))

  $("a.reject-cancel").click (event) ->
    event.preventDefault()
    $(this).closest('div.reject-artwork-request').hide()


