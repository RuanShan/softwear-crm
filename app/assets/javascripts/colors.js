function initializeColorHexcodes() {
  $('.color-hexcodes').minicolors({
    theme: 'bootstrap',
    letterCase: 'uppercase'
  });

  $('.remove-hexcode').off('click.toRemove');
  $('.remove-hexcode').on('click.toRemove', function(e) {
    e.preventDefault();
    $(this).closest('.hexcode').remove();
  });
}

$(function() {
  initializeColorHexcodes();

  var hexcodeContainer = $('#color-hexcodes-container');
  if (hexcodeContainer.length === 0) return;

  var hexcodeContent = hexcodeContainer.data('hexcode');

  $('#add-hexcode').click(function(e) {
    e.preventDefault();
    hexcodeContainer.find('.end').before(hexcodeContent);
    initializeColorHexcodes();
  });
});
