@initializeJobsChosen = ->
  $("#artwork_request_job_ids").select2
    placeholder: "Select all jobs for this request"
    width: "400px"

$(document).ready ->
  $(document).on "change", "#artwork_imprint_method_fields", ->
    if $(this).find(":selected").attr("value")?
      ajax = $.ajax
        url: $(this).data("url") + "/" + $(this).find(":selected").attr("value")
        dataType: "script"
      ajax.done ->
        styleCheckboxes()
