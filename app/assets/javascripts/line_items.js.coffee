$(window).ready ->
  $('.add-line-item').click ->
    $this = $(this)
    $this.attr 'disabled', 'disabled'
    setTimeout (-> $this.removeAttr 'disabled'), 1000

    $('#lineItemModal-'+$this.attr 'data-id').modal 'show'
  $(".line-item-form input[type='radio']").click ->
    alert 'AAAAAAAAAAAAH ' + $this.attr 'data-id'
