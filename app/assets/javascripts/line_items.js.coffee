@initializeLineItemModal = ($lineItemModal) ->
  $currentFormDiv = $('#li-standard-form')
  currentForm = -> $currentFormDiv.find('form')

  $('#lineItemModal').data('current-form-div', $currentFormDiv);

  errorHandler = null

  #console.log 'SETTING THAT SHIT'
  $('input:radio[name="is_imprintable"]').change ->
    $radio = $(this)
    $radio.attr 'disabled', 'disabled'
    setTimeout (-> $radio.removeAttr 'disabled'), 1000

    $out = null
    $in = null
    if $(this).val() is 'yes'
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
    #console.log 'I am submitting it.'
    $('#lineItemModal').data('current-form-div').find('form').submit();
    return

  $lineItemModal.keyup (key) ->
    $('#line-item-submit').click() if key.which is 13 # enter key

  handleImprintableForm = ($form) ->
    $select_level = (num) -> $(".select-level[data-level='#{num}']")
    clearSelectLevel = (num, after) ->
      $selected =
        $(".select-level[data-level='#{num}'] *:not(div.select-level)")
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
        errorModal 'Internal server error (or the internet is down). Sorry!'
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
        $responseSelect.select2()
        $responseSelect.change ->
          data.brand_id = $(this).val()
          data.clear 'imprintable_id', 'color_id'

          ajax = getOptions data, (response) ->
            $response = $(response)
            console.log($response.text())
            clearSelectLevel 2, ->
              $response.hide()
              unless /Brand/.test($response.text())
                $select_level(2).prepend $response
                $response.fadeIn()
                $responseSelect = $response.find('select')
                $responseSelect.select2()
                $responseSelect.change ->
                  data.imprintable_id = $(this).val()
                  data.clear 'color_id'

                  ajax = getOptions data, (response) ->
                    $response = $(response)
                    clearSelectLevel 3, ->
                      $response.hide()
                      unless /Imprintable/.test($response.text())
                        $select_level(3).prepend $response
                        $response.fadeIn()
                        $responseSelect = $response.find('select')
                        $responseSelect.select2()
                        $responseSelect.change ->
                          data.color_id = $(this).val()

                          ajax = getOptions data, (response) ->
                            $response = $(response)
                            clearSelectLevel 4, ->
                              $response.hide()
                              unless /Color/.test($response.text())
                                $select_level(4).prepend $response
                                $response.fadeIn()

  handleImprintableForm $('#li-imprintable-form')
  $lineItemModal.modal 'show'
  $lineItemModal.find('#is_imprintable_no').prop('checked', false)

@imprintableEditEntryChanged = ($this) ->
  console.log("LE GASP")
  $this.addClass("editing-line-item")

jQuery ->
  $('#request_product_id').change ->
    $.ajax url: '/line_items/' + this.value + '/form_partial'
