$(function() {
  if (('.fba-job-template-form').length <= 0) return;

  $(document).on('change', '.imprint-method-select', function() {
    $.ajax({
      type: 'GET',
      url: Routes.print_locations_fba_job_templates_path(),
      data: { imprint_method_id: $(this).val() },
      dataType: 'script'
    });
  });

  $(document).on('click', '.select-artwork', function(e) {
    e.preventDefault();

    // Sort of a silly hack - nested_form obscures the ID of the new object and gives me
    // no way to differentiate between imprint forms on the javascript level.
    var idField = $(this).siblings('input[type=hidden]');
    if (idField.length === 0) {
      alert("The form is configured incorrectly (dev's fault unless you messed with the page somehow)");
      return;
    }

    $.ajax({
      type: 'GET',
      url: $(this).attr('href'),
      data: {
        target: idField.prop('id'),
      }
    });
  });
});
