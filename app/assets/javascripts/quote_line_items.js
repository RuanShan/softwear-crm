$(function() {
  if ($('.edit-quote-line-items').length != 0)
    initializeQuoteLineItems();

  // HACK this "fixes" an issue with non-imprintable line items ending up out of the
  // markups and options job... The spans come from
  // quotes/edit/_line_items_imprintable.html.erb and quote_helper.rb
  var bustedLineItemCount = $('.line-item-was-busted').length;
  if (bustedLineItemCount > 0) {
    $('.line-item-was-busted').remove();
    var message = bustedLineItemCount > 1 ?
      bustedLineItemCount+" line items" : "One of the line items"

    errorModal(
      message + " in this quote somehow became invalid, and was automatically removed." +
      "Make sure nothing important is missing."
    );
  }
});

function initializeExistingLineItemGroupSelect() {
  var select = $('#select-existing-group');
  var groupId = select.val();
  var allFieldValues = select.data('autofill');

  var fieldValues = allFieldValues[groupId];

  $('#line-item-quantity').val(fieldValues.quantity);
  $('#line-item-decoration-price').val(fieldValues.decoration_price);
}

function initializeQuoteNewLineItems() {
  $('.check-for-imprintables').submit(function(event) {
    var fields = $(this).serializeArray();
    var hasImprintables = false;

    fields.forEach(function(field) {
      if (field.name.match(/\[imprintables\]/g)) hasImprintables = true;
    })

    if (!hasImprintables) {
      $('.error-space').text("Please mark at least one imprintable to be added.");
      shine('.error-space', false, 1000, '#D97185');
      return false;
    }
  });
}

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
      $(this).find('li').each(function() {
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

      if ($(this).find('li').length != 0)
        notifyUnsavedChanges();
    }
  });

  $('.option-and-markup-line-item').each(function() {
    if ($(this).parent().hasClass("fields")) {
      $(this).parent().attr('data-line-item-id', $(this).data('line-item-id'));
    }
  });

  var optionMarkups = $('.option-and-markup-line-items');
  optionMarkups.sortable({
    update: function(event, unorderedListElement) {
      $.post(
        Routes.line_item_update_sort_orders_path(optionMarkups.data('job-id')),
        { categories: optionMarkups.sortable("toArray", {attribute: 'data-line-item-id'}) }
      );
    }
  });
}
