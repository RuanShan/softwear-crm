if ($('.edit-quote-line-items').length != 0) $(initializeQuoteLineItems);

function initializeQuoteLineItems() {
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

  $('.job-field').change(function() { $(this).addClass('editing-job-field'); });

  $('.line-item-edit-field').change(function(e) {
    var container = $(this).closest('.sortable-quote-line-item,.option-and-markup-line-item');
    var total = container.find('.line-item-total-price');

    var imprintablePrice = parseFloat(container.find('.imprintable-price').val());
    var decorationPrice = parseFloat(container.find('.decoration-price').val());
    total.text('$' + (imprintablePrice + decorationPrice).toFixed(2));

    $(this).addClass('editing-line-item');

    notifyUnsavedChanges();
  });

  $('.remove-all-line-items-btn').click(function(e) {
    e.preventDefault();
    $(this).parent().find('.rdy-to-remove').click();
  });

  $('.remove-line-item-btn').addClass('rdy-to-remove');
  $('.remove-line-item-btn').click(function(e) {
    e.preventDefault();
    var button       = $(this);
    var container    = button.closest('.sortable-quote-line-item,.option-and-markup-line-item');
    var destroyField = container.find('.line-item-destroy-field');
    var allFields    = container.find('.line-item-edit-field');

    if (container.length <= 0) {
      alert('Could not find container of remove button');
      return;
    }
    if (allFields.length <= 0) {
      alert('No input fields att all???');
      return;
    }
    if (destroyField.length <= 0) {
      alert('Could not find field with name~="_destroy"');
      return;
    }

    if (button.data('removing')) {
      container.removeClass('removing-line-item');
      button.data('removing', false);
      button.text('Remove');
      button.addClass('rdy-to-remove');
      destroyField.val('false');
      destroyField.prop('disabled', 'disabled');
      allFields.removeProp('disabled');
    }
    else {
      container.addClass('removing-line-item');
      button.data('removing', true);
      button.text('Unremove');
      button.removeClass('rdy-to-remove');
      destroyField.val('true');
      destroyField.removeProp('disabled');
      allFields.prop('disabled', 'disabled');

      notifyUnsavedChanges();
    }
  });

  $('ul.edit-quote-line-items').each(function() {
    var ul = $(this);
    // Assuming each input directly under the ul is a rails-generated id input.
    ul.children('input').each(function() {
      var input = $(this);
      var lineItemId = input.val();

      input.appendTo(ul.find('li[data-line-item-id='+lineItemId+']'));
    });
  });

  $(".edit-quote-line-items").sortable({
    connectWith: ".sortable-quote-line-items",

    update: function( event, ui ) {
      $(this).children('li').each(function() {
        var li = $(this);
        var ul = li.closest('ul');

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
        }
      });

      if ($(this).children('li').length != 0)
        notifyUnsavedChanges();
    }
  });
}
