@initializeLineItemModal = ($lineItemModal, fromJsResponse) ->
  $currentFormDiv = null
  currentForm = -> $currentFormDiv.find('form')

  $('#lineItemModal').data('current-form-div', $currentFormDiv);

  errorHandler = null

  console.log 'SETTING THAT SHIT'
  $('input:radio[name="is_imprintable"]').change ->
    $radio = $(this)
    $radio.attr 'disabled', 'disabled'
    setTimeout (-> $radio.removeAttr 'disabled'), 1000

    $out = null
    $in = null
    if $(this).val() == 'yes'
      $out = $('#li-standard-form')
      $in  = $('#li-imprintable-form')
    else
      $out = $('#li-imprintable-form')
      $in  = $('#li-standard-form')

    $out.fadeOut 400, ->
      errorHandler.clear() if errorHandler != null
      errorHandler = null
      $currentFormDiv = $in
      $('#lineItemModal').data('current-form-div', $currentFormDiv);
      $in.fadeIn 400

  $('#line-item-submit').click ->
    console.log 'I am submitting it.'
    $('#lineItemModal').data('current-form-div').find('form').submit();
    return

  $lineItemModal.keyup (key) ->
    $('#line-item-submit').click() if key.which is 13 # enter key

  handleImprintableForm = ($form) ->
    $select_level = (num) -> $(".select-level[data-level='#{num}']")
    clearSelectLevel = (num, after) ->
      $selected = $(".select-level[data-level='#{num}'] *:not(div.select-level)")
      if $selected.size() > 0
        # console.log 'clearing after fade out'
        did_callback = false
        $selected.fadeOut ->
          $selected.remove()
          after() unless after is null or did_callback
          did_callback = true
      else
        # console.log 'clearing before fade out'
        after() if after
    getOptions = (data, done) ->
      a = $.ajax
        type: 'GET'
        url: '/line_item/select_options'
        data: data
      a.fail (jqXHR, textStatus) ->
        errorModal('Internal server error (that or the internet is down). Sorry!')
      a.done(done) unless done is null
      a

    ajax = getOptions()
    ajax.done (response) ->
      data =
        brand_id: null
        imprintable_id: null
        color_id: null
        clear: (attrs...) -> this[attr] = null for attr in attrs
      $response = $(response)
      clearSelectLevel 1, ->
        $response.hide()
        $select_level(1).prepend $response
        $response.fadeIn()
        $responseSelect = $response.find('select')
        $responseSelect.change ->
          data.brand_id = $(this).val()
          data.clear 'imprintable_id', 'color_id'

          ajax = getOptions data, (response) ->
            $response = $(response)
            clearSelectLevel 2, ->
              $response.hide()
              $select_level(2).prepend $response
              $response.fadeIn()
              $responseSelect = $response.find('select')
              $responseSelect.change ->
                data.imprintable_id = $(this).val()
                data.clear 'color_id'

                ajax = getOptions data, (response) ->
                  $response = $(response)
                  clearSelectLevel 3, ->
                    $response.hide()
                    $select_level(3).prepend $response
                    $response.fadeIn()
                    $responseSelect = $response.find('select')
                    $responseSelect.change ->
                      data.color_id = $(this).val()

                      ajax = getOptions data, (response) ->
                        $response = $(response)
                        clearSelectLevel 4, ->
                          $response.hide()
                          $select_level(4).prepend $response
                          $response.fadeIn()


  handleImprintableForm $('#li-imprintable-form')
  $lineItemModal.modal 'show'
  $lineItemModal.find('#is_imprintable_no').prop('checked', false)

@imprintableEditEntryChanged = ($this) ->
  $this.parentsUntil(".line_item").parent().addClass("editing-line-item")

loadLineItemView = (lineItemId, url) ->
  $row = $("#line-item-#{lineItemId}")
  $oldChildren = $row.children()

  ajax = $.ajax
    type: 'GET'
    url: url
    dataType: 'json'

  ajax.done (response) ->
    $oldChildren.each -> $(this).remove()
    $row.append response.content

    if document.URL.split('/')[3] == 'jobs'
      updateOrderTimeline()

@editLineItem = (lineItemId) ->
  loadLineItemView lineItemId, Routes.edit_line_item_path(lineItemId)

@cancelEditLineItem = (lineItemId) ->
  loadLineItemView lineItemId, Routes.line_item_path(lineItemId)

@deleteLineItem = (lineItemId) ->
  $(this).attr 'disabled', 'disabled'

  $row = $("#line-item-#{lineItemId}")
  ajax = $.ajax
    type: 'DELETE'
    url: "/line_items/#{lineItemId}"
    dataType: 'json'

  ajax.done (response) ->
    if response.result == 'success'
      $row.fadeOut -> $row.remove()
      if document.URL.split('/')[3] == 'jobs'
        updateOrderTimeline()
    else if response.result == 'failure'
      alert "Something weird happened and the line item couldn't be deleted."

@deleteLineItems = (lineItemIds, imprintableName, class_name) ->
  $(this).attr 'disabled', 'disabled'

  $row = $('#'+imprintableName)
  ajax = $.ajax
    type: 'DELETE'
    url: "/line_items/#{lineItemIds}"
    dataType: 'json'

  ajax.done (response) ->
    if response.result == 'success'
      $row.fadeOut -> $row.remove()
      if class_name == 'Job'
        updateOrderTimeline()
    else
      alert 'Something weird happened and the line items could not be deleted.'

@updateLineItems = (parentSelector) ->
  selector = '.editing-line-item'
  selector = "#{parentSelector} #{selector}" if parentSelector

  $(selector).each (i) ->
    $this = $(this)
    ajax = $.ajax
      type: 'PUT'
      url: $this.attr 'action'
      data: $this.serialize()
      dataType: 'json'

    ajax.done (response) ->
      $container = $this.parent()
      $container.children().each -> $(this).remove()
      $content = $(response.content)
      $container.append $content
      if response.result == 'failure'
        eh = ErrorHandler('line_item', $container.find('form'))
        eh.handleErrors(response.errors, response.modal)
      else
        $inputs = $content.find 'input'
        shine $inputs, true
        shine $content, false


    ajax.fail (jqXHR, errorText) ->
      alert "Internal server error! Can't process request."

  if (class_name == 'Job')
    after 5000, updateOrderTimeline

# Opens the modal to create a new line item.
@addLineItem = (line_itemable_id, class_name) ->
  $this = $(this)
  $this.attr 'disabled', 'disabled'
  setTimeout (-> $this.removeAttr 'disabled'), 1000
  # TODO if modal is already present, kill it and return maybe?

  url = ''
  if class_name == 'Job'
    url = Routes.new_job_line_item_path(line_itemable_id)
  else if class_name == 'Quote'
    url = Routes.new_quote_line_item_path(line_itemable_id)

  ajax = $.ajax
    type: 'GET'
    url: url
    dataType: 'html'

  ajax.done (response) ->
    $('body').append $(response)
    $lineItemModal = $('#lineItemModal')
    initializeLineItemModal $lineItemModal
    $lineItemModal.on 'hidden.bs.modal', (e) ->
      $lineItemModal.remove()

  ajax.fail (jqXHR, textStatus) ->
    alert "Internal server error! Can't process request."

jQuery ->
  $('#request_product_id').change ->
    $.ajax({
      url: '/line_items/' + this.value + '/form_partial'
    })
