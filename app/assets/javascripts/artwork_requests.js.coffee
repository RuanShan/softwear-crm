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
        url: Routes.imprint_ink_colors_path($(this).find(":selected").attr("value"))
        dataType: "script"
      ajax.done ->
        styleCheckboxes()
