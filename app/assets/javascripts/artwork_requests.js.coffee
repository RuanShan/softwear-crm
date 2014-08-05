@initializeJobsChosen = ->
  $("#artwork_request_job_ids").chosen
    placeholder_text_multiple: "Select all jobs for this request"
    no_results_text: "No results matched"
    width: "400px"

# TODO possibly create global function since repeated in proofs.js.coffee
@setNewArtworkRequestSelect = ->
  $(".artwork-status-select").hide()
  $(".artwork-status-select").val "Pending"

$(document).ready ->
  $(document).on "change", "#artwork_imprint_method_fields", ->
    if $(this).find(":selected").attr("value")?
      ajax = $.ajax
        url: $(this).data("url") + "/" + $(this).find(":selected").attr("value")
        dataType: "script"
      ajax.done ->
        styleCheckboxes()
