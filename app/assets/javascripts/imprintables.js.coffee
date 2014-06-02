jQuery ->
  brand = $('#imprintable_brand_id :selected').text()
  if (brand == 'Select a Brand')
    $('#imprintable_style_id').parent().parent().hide()
  styles = $('#imprintable_style_id').html()
  $('#imprintable_brand_id').change ->
    brand = $('#imprintable_brand_id :selected').text()
    escaped_brand = brand.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    options = $(styles).filter("optgroup[label='#{escaped_brand}']").html()
    if options
      $('#imprintable_style_id').html(options)
      $('#imprintable_style_id').parent().parent().show()
    else
      $('#imprintable_style_id').empty()
      $('#imprintable_style_id').parent().parent().hide()
