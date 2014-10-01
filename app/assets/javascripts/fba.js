var packingSlipUpload = function(closeButton) {
  return "\
  <div class='row'>\
    <div class='col-sm-6'>\
      <input type='file' name='packing_slips[]' accept='text/txt' class='js-packing-slip' />\
    </div>\
    "
    + (closeButton ? "\
        <div class='col-sm-6'>\
          <a href='#' onclick='$(this).closest(\".row\").remove();'>\
            <i class='fa fa-2x danger fa-times-circle'></i>\
          </a>\
        </div>\
        " : "")

    + "</div>";
}


$(function() {
  $('#js-packing-slips').append(packingSlipUpload(false));

  $('#js-add-packing-slip-file').click(function() {
    $('#js-packing-slips').append(packingSlipUpload(true));
  });

  $('#js-upload-packing-slips-button').click(function() {
    $('#packingSlipModal').modal('show');
  });

  $('#js-packing-slip-form').submit(function() {
    $('#packingSlipModal').modal('hide');
    return true;
  });
});
