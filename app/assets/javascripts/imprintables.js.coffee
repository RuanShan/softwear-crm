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

  intersect_arrays = (x, y) ->
    z = []
    count = 0
    for item_one in x
      for item_two in y
        if item_one == item_two
          z[count] = item_one
          count += 1
          continue
    return z

  change_cells = (class_name, element) ->
    if /row_/.test(element.attr('id'))
#     need to change an entire row
      tds = document.querySelectorAll('#' + element.closest('tr').attr('id').concat(' td'))
      for item in tds
        item.firstElementChild.className = class_name
    else if /col_/.test(element.attr('id'))
      sub = element.attr('id').split('_')[2]
      sub = 'i[id$=_' + sub.toString() + ']'
      array_one = document.querySelectorAll('i[id^=cell_]')
      array_two = document.querySelectorAll(sub)
      union = intersect_arrays(array_one, array_two)
      for item in union
        item.className = class_name
    else if /cell/.test(element.attr('class'))
      element = element.prev() until /cell_\d*_\d*/.test(element.attr('id'))
      document.getElementById(element.attr('id')).className = class_name

  $('.fa-plus').click ->
    change_cells('fa fa-check', $(this))

  $('.fa-minus').click ->
    change_cells('fa fa-times', $(this))
