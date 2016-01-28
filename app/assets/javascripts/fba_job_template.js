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
});
