@calculate_expected = ->
  cash_sum = 0.0
  check_sum = 0.0
  $('.undropped-payment').each ->
    if $(this).prop('checked') && $(this).data('payment-method') == 1
      cash_sum = cash_sum + parseFloat($(this).data('payment-amount'))
    else if $(this).prop('checked') && $(this).data('payment-method') == 3
      check_sum = check_sum + parseFloat($(this).data('payment-amount'))

  cash_total = ('$' + parseFloat(cash_sum, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());
  expected_cash = $("#payment_drop_cash_included").val()
  expected_cash_total = ('$' + parseFloat(expected_cash, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());

  check_total = ('$' + parseFloat(check_sum, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());
  expected_check = $("#payment_drop_check_included").val()
  expected_check_total = ('$' + parseFloat(expected_check, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());

  if expected_cash_total != cash_total || expected_check_total != check_total
    $("#payment_drop_difference_reason").removeAttr('disabled')
  else
    $("#payment_drop_difference_reason").attr('disabled', true)

  $("#expected-cash-included").html("Expected cash total " + cash_total)
  $("#expected-check-included").html("Expected check total " + check_total)

@prepare_payments_for_drop = ->
  $('.undropped-payment').change ->
    expected_cash = calculate_expected()
    c = ''
    if $(this).prop('checked')
      c = '#f9f9f9'
      $(this).data('checked', true)
    $(this).parents('tr').css('background-color', c);
  calculate_expected()

jQuery ->
  $("#payment_drop_cash_included, #payment_drop_check_included").change ->
    calculate_expected()

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



