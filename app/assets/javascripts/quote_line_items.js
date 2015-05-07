function updateLineItemTotal() {
}

$(function() {
  if ($('.edit-quote-line-items').length == 0) return;

  function jobIdFor(element) {
    return element.closest('.quote-job-entry').data('job-id');
  }
  function tierFor(element) {
    return element.closest('.tier-row').data('tier');
  }

  $('.line-item-edit-field').change(function(e) {
    var container = $(this).closest('.sortable-quote-line-item');
    var total = container.find('.line-item-total-price');

    var imprintablePrice = parseFloat(container.find('.imprintable-price').val());
    var decorationPrice = parseFloat(container.find('.decoration-price').val());
    total.text('$' + (imprintablePrice + decorationPrice).toFixed(2));

    $(this).addClass('editing-line-item');
  });

  $(".edit-quote-line-items").sortable({
    connectWith: ".sortable-quote-line-items",

    update: function( event, ui ) {
      var element = $(this);
      var jobId = jobIdFor(element);
      var tier = tierFor(element);

      var jobField = element.find('.job-id-field');
      var tierField = element.find('.tier-field');

      var jobChanged = parseInt(jobField.val()) != parseInt(jobId);
      // TODO These changed bools are absolutly not getting assigned correctly.
      var tierChanged = parseInt(tierField.val()) != parseInt(tier);

      if (jobId != null && jobChanged)
        element.find('.job-id-field').val(jobId);
      if (tier != null && tierChanged)
        element.find('.tier-field').val(tier);

      // element.addClass('editing-line-item');
      if (tierChanged || jobChanged)
        element.find('.sortable-quote-line-item').addClass('editing-line-item');
    }
  });
});
