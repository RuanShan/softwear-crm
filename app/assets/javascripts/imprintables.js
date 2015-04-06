$(function() {
  $('.upcharge-check-box').on('ifChanged', function() {

    var field = $('.upcharge-' + $(this).data('for'));
    field.prop('disabled', !this.checked);

  });
});
