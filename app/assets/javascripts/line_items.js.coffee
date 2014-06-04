$(window).ready ->
  $('.add-line-item').click ->
    $this = $(this)
    $this.attr 'disabled', 'disabled'
    setTimeout (-> $this.removeAttr 'disabled'), 1000
    # TODO if modal is already present, kill it and return maybe

    ajax = $.ajax
      type: 'GET',
      url: "/jobs/#{$this.attr 'data-id'}/line_items/new"
      dataType: 'html'

    ajax.done (response) ->
      console.log response
      $('body').children().last().after $(response)
      lineItemModal = $('#lineItemModal')
      initializeLineItemModal lineItemModal
      lineItemModal.on 'hidden.bs.modal', (e) ->
        lineItemModal.remove()

    ajax.fail (jqXHR, textStatus) ->
      alert "Internal server error! Can't process request."

initializeLineItemModal = (lineItemModal) ->
  currentForm = null

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
      currentForm = $in
      $in.fadeIn 400

  $('#line-item-submit').click ->
    $add = $(this)
    $add.attr 'disabled', 'disabled'
    setTimeout (-> $add.removeAttr 'disabled'), 5000

    # TODO change to ajaxSubmit/ajaxForm
    currentForm.submit()

  lineItemModal.modal 'show'