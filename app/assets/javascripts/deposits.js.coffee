# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@calculate_expected_deposit = ->
  cash_sum = 0.0
  check_sum = 0.0
  $('.undeposited-payment-drop').each ->
      if $(this).parent('div').hasClass('checked')
        cash_sum = cash_sum + parseFloat($(this).data('cash-included'))
        check_sum = check_sum + parseFloat($(this).data('check-included'))

  cash_total = ('$' + parseFloat(cash_sum, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());
  expected_cash = $("#deposit_cash_included").val()
  expected_cash_total = ('$' + parseFloat(expected_cash, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());

  check_total = ('$' + parseFloat(check_sum, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());
  expected_check = $("#deposit_check_included").val()
  expected_check_total = ('$' + parseFloat(expected_check, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString());

  if expected_cash_total != cash_total || expected_check_total != check_total
    $("#deposit_difference_reason").removeAttr('disabled')
  else
    $("#deposit_difference_reason").attr('disabled', true)

  $("#expected_cash").html(cash_total)
  $("#expected_check").html(check_total)


$ ->
  $("#deposit_cash_included, #deposit_check_included").change ->
    calculate_expected_deposit()
  $('.calculate-undeposited').click ->
    calculate_expected_deposit()
  return
