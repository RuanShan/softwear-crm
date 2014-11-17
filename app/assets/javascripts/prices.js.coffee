jQuery ->
#  whenever the button is clicked toggle view of both the text and select inputs
  $(document).on('click', '#add-a-price', ->
    $('#pricing-group-input').toggle()
    $('#pricing-group-select').toggle()
  )
