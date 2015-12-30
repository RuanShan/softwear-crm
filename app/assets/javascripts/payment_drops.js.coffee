@calculate_expected_cash = ->
  sum = 0.0
  $('.undropped-payment').each ->
    if $(this).prop('checked') && $(this).data('payment-method') == 1
      sum = sum + $(this).data('payment-amount')
  total = ('$' + parseFloat(sum, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());
  expected = $("#payment_drop_cash_included").val()
  expected_total = ('$' + parseFloat(expected, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());
  if expected_total != total
    $("#payment_drop_difference_reason").removeAttr('disabled')
  else
    $("#payment_drop_difference_reason").attr('disabled', true)

  $("#expected-cash-included").html("Expected cash total " + total)

@prepare_payments_for_drop = ->
  $('.undropped-payment').change ->
    expected_cash = calculate_expected_cash()
    c = ''
    if $(this).prop('checked')
      c = '#f9f9f9'
      $(this).data('checked', true)
    $(this).parents('tr').css('background-color', c);
  calculate_expected_cash()

jQuery ->
  $("#payment_drop_cash_included").change ->
    calculate_expected_cash()

  prepare_payments_for_drop()

  $('#payment_drop_store_id').change ->
    if $(this).val() != ''
      ajax = $.ajax
        url: Routes.payments_undropped_path()
        dataType: "script"
        data:
          store_id: $(this).val()
#    ajax.done ->
#      styleCheckboxes()



