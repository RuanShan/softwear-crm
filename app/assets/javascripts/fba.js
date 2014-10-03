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
  if ($('#js-packing-slip-form').length == 0) return;

  var currentDatas = [];

  // $('#js-packing-slips').append(packingSlipUpload(false));

  $('#js-add-packing-slip-file').click(function() {
    $('#js-packing-slips').append(packingSlipUpload(true));
  });

  $('#js-upload-packing-slips-button').click(function() {
    $('#packingSlipModal').modal('show');
  });

  $('#js-packing-slip-form').submit(function() {
    $('#packingSlipModal').modal('hide');

    $('#js-packing-slip-form').replaceWith($(this).clone())

    return true;
  });

  $('#js-packing-slip-form').fileupload({
    dataType: 'script',
    add: function(e, data) {
      var file = data.files[0];
      // currentDatas.push(data);

      data.context = $(tmpl('template-upload', file));
      $('#js-packing-slip-info-zone').append(data.context);
      data.context.data('file-data', data);

      data.submit();
      $('#packingSlipModal').modal('hide');
    },

    progress: function(e, data) { }
  });
});
