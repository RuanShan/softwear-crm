$(function() {
  if ($('#mass-cost-form').length > 0) {

    // When multiple line items correspond to one imprintable variant,
    // assume they are of the same size (only if multi-input is checked).
    $('input.cost-amount').on('input', function() {
      if (!$('#multi_input')[0].checked)
        return;
      var $this = $(this);

      $('.iv-'+$this.data('iv')+'-cost').val($this.val());
    });
  }
});
