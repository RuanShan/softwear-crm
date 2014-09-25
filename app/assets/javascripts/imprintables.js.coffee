root = exports ? this

jQuery ->

  # this function is modified from an example hosted publicly at
  # http://www.mredkj.com/tutorials/tableaddcolumn.html
  addColumn = (tableId, size, size_id) ->
    tableHeadObject = document.getElementById(tableId).tHead
    select = document.getElementById("add_a_size")

    # first make sure size hasn't already been selected
    tableHeaders = tableHeadObject.rows[0].cells

    h = 0
    while h < tableHeaders.length
      if size is tableHeaders[h].outerText
        unless confirm("This would create a duplicate size, are you sure you wish to proceed?")
          return
        else
          break
      ++h

    h = 0
    while h < tableHeadObject.rows.length
      row = tableHeadObject.rows[h]

      newTH = document.createElement("th")
      newTH.id = "col_#{String(row.cells.length - 1)}"
      newTH.setAttribute "data-size-id", size_id

      tableHeadObject.rows[h].deleteCell row.cells.length - 1
      tableHeadObject.rows[h].appendChild newTH

      headerPlus = document.createElement("i")
      headerMinus = document.createElement("i")

      headerPlus.id = "col_plus_#{ String(row.cells.length - 1) }"
      headerMinus.id = "col_minus_#{ String(row.cells.length - 1) }"

      newTH.innerHTML = size

      headerPlus.className = "fa fa-plus"
      headerMinus.className = "fa fa-minus"

      newTH.appendChild headerPlus
      newTH.appendChild headerMinus

      tableHeadObject.rows[h].appendChild select
      ++h

    tblBodyObj = document.getElementById(tableId).tBodies[0]

    i = 0
    row = tableHeadObject.rows[0]
    while i < tblBodyObj.rows.length - 1
      newCell = tblBodyObj.rows[i].insertCell(-1)
      newCell.id = "cell_#{ String(i + 1) }_#{ String(row.cells.length - 2) }"

      cellPlus = document.createElement("i")
      cellMinus = document.createElement("i")

      cellPlus.className = "fa fa-plus cell"
      cellMinus.className = "fa fa-minus cell"

      check = document.createElement("i")
      check.className = "fa fa-check changed"
      check.id = "image_#{ String(i + 1) }_#{ String(row.cells.length - 2) }"

      newCell.appendChild check
      newCell.appendChild cellPlus
      newCell.appendChild cellMinus
      ++i
    return

  addRow = (color, color_id) ->
    table = document.getElementById('imprintable_variants_list')
    tableBodyObject = table.tBodies[0]

    # first make sure the color hasn't already been selected
    rowCount = tableBodyObject.rows.length - 1
    while rowCount >= 0
      if (tableBodyObject.rows[rowCount].cells[0].outerText is color)
        if(!confirm("This would create a duplicate color, are you sure you wish to proceed?"))
          return
        else
          break
      rowCount -= 1

    count = tableBodyObject.rows[0].cells.length
    cellIndex = 0
    row = table.insertRow(tableBodyObject.rows.length)

    if count > 0
      rowHeader = document.createElement('th')
      row.id = "row_#{ String(tableBodyObject.rows.length-1) }"

      row.setAttribute('data-color-id', color_id)
      cellIndex += 1
      count -= 1

      headerPlus = document.createElement('i')
      headerMinus = document.createElement('i')

      headerPlus.className = 'fa fa-plus'
      headerPlus.id = "row_plus_#{ String(tableBodyObject.rows.length) }"

      headerMinus.className = 'fa fa-minus'
      headerMinus.id = "row_minus_#{ String(tableBodyObject.rows.length) }"

      rowHeader.innerHTML = color
      rowHeader.appendChild(headerPlus)
      rowHeader.appendChild(headerMinus)

      row.appendChild(rowHeader)

    while count > 0
      # create new cell with times sign
      newCell = row.insertCell(cellIndex)
      count -= 1

      newCell.id = "cell_#{ String(tableBodyObject.rows.length-1) }_#{ String(cellIndex) }"

      cellCheck = document.createElement('i')
      cellMinus = document.createElement('i')
      cellPlus = document.createElement('i')

      cellCheck.className = 'fa fa-check changed'
      cellCheck.id = "image_#{ String(tableBodyObject.rows.length-1) }_#{ String(cellIndex) }"

      cellIndex += 1

      cellPlus.className = 'fa fa-plus cell'
      cellMinus.className = 'fa fa-minus cell'

      newCell.appendChild(cellCheck)
      newCell.appendChild(cellPlus)
      newCell.appendChild(cellMinus)
    return

  if $('#sample_location_ids').length
    stores = $('#sample_location_ids').data()['stores']
    store_name_array = []
    for store in stores
      store_name_array.push(store[0])
    $('#sample_location_ids').on('tokenfield:createtoken', (e) ->
      for store in stores
        if e.attrs.label is store[0]
          e.attrs.value is store[1]
    ).tokenfield({
        autocomplete: {
          source: store_name_array,
          delay: 100
        },
        showAutocompleteOnFocus: true
      })

  intersect_arrays = (x, y) ->
    z = []
    count = 0
    for item_one in x
      for item_two in y
        if item_one is item_two
          z[count] = item_one
          count += 1
          continue
    return z

  change_cell = (class_name, element) ->
    if /row_/.test(element.attr('id'))
      tds = document.querySelectorAll('#' + element.closest('tr').attr('id').concat(' td'))
      for item in tds
        item.firstElementChild.className = String(class_name + ' changed')
    else if /col_/.test(element.attr('id'))
      sub = element.attr('id').split('_')[2]
      sub = 'i[id$=_' + sub.toString() + ']'
      array_one = document.querySelectorAll('i[id^=image_]')
      array_two = document.querySelectorAll(sub)
      union = intersect_arrays(array_one, array_two)
      for item in union
        item.className = String(class_name + ' changed')
    else if /cell/.test(element.attr('class'))
      element = element.prev() until /image_\d*_\d*/.test(element.attr('id'))
      if element.prop("class") is class_name
        return
      else
        element.prop("class", String(class_name + ' changed'))

  aggregate_variants =  ->
    variants_to_remove = []
    variants_to_add = []
    variants = $('.changed')

    for variant in variants
      if $(variant).prop('class') is 'fa fa-check changed'
        # add variant
        sub = $(variant).attr('id').split('_')[2]
        colhead = document.querySelectorAll('#col_'+String(sub))
        size_id = $(colhead).attr('data-size-id')

        sub = $(variant).attr('id').split('_')[1]
        rowhead = document.querySelectorAll('#row_'+String(sub))
        color_id = $(rowhead).attr('data-color-id')

        variants_to_add.push({ size_id: size_id, color_id: color_id })

      else if $(variant).prop('class') is 'fa fa-times changed'
        # remove variant
        variants_to_remove.push($(variant).attr('data-variant-id'))

    return { variants_to_add: variants_to_add, variants_to_remove: variants_to_remove }

  populate_color_and_size_ids = ->
    color_ids = new Array
    size_ids = new Array
    checked = $(".checked")
    for item in checked
      if($(item).parent().parent().prev().text() is 'Color')
        color_ids.push($(item).children().first().attr('value'))
      else if ($(item).parent().parent().prev().text() is 'Size')
        size_ids.push($(item).children().first().attr('value'))
    return {color_ids: color_ids, size_ids: size_ids}

  $('.chosen-select').chosen()


#  $(document).on(load, ->
#    $('.chosen-select').chosen()
#  )

  get_id = ->
    url_array = document.URL.split('/')
    id = url_array[url_array.length - 2]
    return id

  $(document).on('click', '#size_button', ->
    size = $('#size_select_chosen .chosen-single span').text()
    if size is 'Select a Size'
      return
    addColumn('imprintable_variants_list', size, root.size_id)
  )

  $(document).on('click', '#color_button', ->
    color = $('#color_select_chosen .chosen-single span').text()
    if color is 'Select a Color'
      return
    addRow(color, root.color_id)

  )

  $(document).on('click', '.fa-plus',  ->
    change_cell('fa fa-check', $(this))
  )

  $(document).on('click', '.fa-minus', ->
    change_cell('fa fa-times', $(this))
  )

#  $('.color-size-chosen-select').chosen( { width: '200px' } )
  $('#color-select').chosen( { width: '200px' }).change( (event) ->
    if(event.target == this)
      root.color_id = $(this).val()
  )

  $('#size-select').chosen( { width: '200px' }).change ( (event) ->
    if(event.target == this)
      root.size_id = $(this).val()
  )

  $('.table.table-hover').fixedHeader()

  $(document).on('click', '#submit_button', ->
    innerHtml = document.getElementById('submit_button').innerHTML
    if /Update Imprintable/.test(innerHtml)
      if $('#imprintable_variants_list').length
        # variants already exist
        # aggregate all the variants and populate params
        pobj = { update: aggregate_variants(), id: get_id() }
        $.post('/imprintables/update_imprintable_variants', pobj)
      else
        # variants don't exist yet
        # populate color_ids and size_ids
        return { update: populate_color_and_size_ids(), id: get_id() }
  )
