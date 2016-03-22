function initCostTypeSelect(context) {
  context.find('.cost-type-select').select2({
    maximumSelectionLength: 1,
    tags: true
  });
}

$(function() {
  $(document).on('nested:fieldAdded:costs', function() {
    initCostTypeSelect($(this));
  });

  initCostTypeSelect($('.order-costs'));
});
