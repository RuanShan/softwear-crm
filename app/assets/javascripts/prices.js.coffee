jQuery ->
#  whenever the button is clicked toggle view of both the text and select inputs
  $(document).on('click', '.toggle-group', ->
    $('#pricing-group-input').toggle();
    $('#pricing-group-select').toggle();
    $('#pricing-group-input-toggle').toggle();
    $('#pricing-group-select-toggle').toggle();

    if $('#pricing_group_text').prop('required')
      $('#pricing_group_text').prop('required', false)
      $('#pricing_group_text').prop('disabled', true)
    else
      $('#pricing_group_text').prop('required', true)
      $('#pricing_group_text').prop('disabled', false)

    if $('#pricing_group_select').prop('required')
      $('#pricing_group_select').prop('required', false)
      $('#pricing_group_select').prop('disabled', true)
    else
      $('#pricing_group_select').prop('required', true)
      $('#pricing_group_select').prop('disabled', false)
  )
