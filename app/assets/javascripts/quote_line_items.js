function updateLineItemTotal() {
}

$(function() {
  if ($('.edit-quote-line-items').length == 0) return;

  $('#save-line-item-changes-btn').click(function(e) {
    $('.job-form-to-be-saved').submit();
  });

  function jobIdFor(element) {
    return element.closest('.quote-job-entry').data('job-id');
  }
  function tierFor(element) {
    return element.closest('.tier-row').data('tier');
  }

  function notifyUnsavedChanges() {
    window.onbeforeunload = function() {
      return 'There are unsaved changes to line items. Are you sure you want to leave?'
    }
  }

  $('.line-item-edit-field').change(function(e) {
    var container = $(this).closest('.sortable-quote-line-item');
    var total = container.find('.line-item-total-price');

    var imprintablePrice = parseFloat(container.find('.imprintable-price').val());
    var decorationPrice = parseFloat(container.find('.decoration-price').val());
    total.text('$' + (imprintablePrice + decorationPrice).toFixed(2));

    $(this).addClass('editing-line-item');

    notifyUnsavedChanges();
  });

  $(".edit-quote-line-items").sortable({
    connectWith: ".sortable-quote-line-items",

    update: function( event, ui ) {
      $(this).children('li').each(function() {
        var element = $(this);

        var jobId = jobIdFor(element);
        var tier  = tierFor(element);

        var jobField  = element.find('.job-id-field');
        var tierField = element.find('.tier-field');

        var jobChanged = jobField[0] !== undefined &&
          parseInt(jobField.val()) != parseInt(jobId);
        var tierChanged = tierField[0] !== undefined &&
          parseInt(tierField.val()) != parseInt(tier);

        if (jobId != null && jobChanged)
          element.find('.job-id-field').val(jobId);
        if (tier != null && tierChanged)
          element.find('.tier-field').val(tier);

        if (tierChanged || jobChanged)
          element.addClass('editing-line-item');
      });

      if ($(this).children('li').length != 0)
        notifyUnsavedChanges();
    }
  });
});
