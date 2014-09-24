function refreshLineItemGroup(id) {
  $.ajax({
    type: 'GET',
    url: Routes.line_item_group_path(id),
    dataType: 'json'
  })
    .done(function(response) {
      $('#line-item-group-'+id).replaceWith(response.content);
      refresh_inlines();
    })
    .fail(function(jquXHR, textStatus) {
      errorModal('Ohhhhh nooooooo (server error)');
    });
}