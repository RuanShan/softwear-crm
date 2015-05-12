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
        var li = $(this);

        var jobId = jobIdFor(li);
        var tier  = tierFor(li);

        var jobField  = li.find('.job-id-field');
        var tierField = li.find('.tier-field');

        var jobChanged = jobField[0] !== undefined &&
          parseInt(jobField.val()) != parseInt(jobId);
        var tierChanged = tierField[0] !== undefined &&
          parseInt(tierField.val()) != parseInt(tier);

        if (jobId != null && jobChanged)
          jobField.val(jobId);
        if (tier != null && tierChanged)
          tierField.val(tier);

        if (tierChanged || jobChanged) {
          li.addClass('editing-line-item');

          var lineItemId  = li.data('line-item-id');
          var indexInName = /job\[\w+_line_items_attributes\]\[((id_)?\d+)\]/;

          li.find('input,textarea,select').each(function() {
            var input = $(this);
            var name = input.prop('name');

            // Replace index portion of input names: job[line_items_attributes][0][field]
            //             -----------------------------------------------------^ that
            // with id_<line_item.id> to indicate that this is an existing line item joining
            // from an external job and/or tier.
            var newName = name.replace(
                // 1st match should be the whole ((id_)?\d+) group
              name.match(indexInName)[1],
              'id_'+lineItemId
            );

            input.prop('name', newName)
          });
        }
      });

      if ($(this).children('li').length != 0)
        notifyUnsavedChanges();
    }
  });
});
