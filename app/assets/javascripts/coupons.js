$(function() {
  $('#coupon_calculator').change(function() {
    var helpBlock = $('#calculator-help-block');
    var descs = helpBlock.data('descriptions');
    if ($(this).val() == '')
      helpBlock.text("Calculator determines what type of discount this coupon applies");
    else
      helpBlock.text(descs[$(this).val()]);
  });
});
