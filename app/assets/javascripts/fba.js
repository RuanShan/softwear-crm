function generateUUID() {
  var d = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-0xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = (d + Math.random()*16)%16 | 0;
    d = Math.floor(d/16);
    return (c=='x' ? r : (r&0x7|0x8)).toString(16);
  });
  return uuid;
};

var resubmitButton;
var resubmitFbaOnEnter;

$(function() {
  if ($('#js-packing-slip-form').length == 0) return;

  resubmitButton = function(self, inputClass) {
    var dataElement =
      self.closest('.fba-upload');

    var container =
      self.closest('.error-result');

    var inputElement =
      container
      .find('.' + inputClass);

    var originalValue =
      inputElement
      .data('original-value');

    var originalOptions =
      dataElement
      .data('original-options');

    if (originalOptions == null)
      originalOptions = {};

    var inputOptions = {};
    var optionValue = {};

    optionValue[originalValue] = inputElement.val();
    inputOptions[inputElement.prop('name')] = optionValue;

    var fileData = dataElement.data('file-data');

    var optionsObj = $.extend(originalOptions, inputOptions);
    dataElement.data('original-options', optionsObj);

    fileData.formData = {
      options: JSON.stringify(optionsObj),
      script_container_id: dataElement.attr('id')
    };
    fileData.submit();

    return true;
  };

  resubmitFbaOnEnter = function(self, event) {
    if ((event.keyCode || event.which) == '13') {
      self
        .closest('.info')
        .find('.fba-resubmit')
        .click();
      return false;
    }
  };

  $('#js-upload-packing-slips-button').click(function() {
    $('#packingSlipModal').modal('show');
  });

  $('#js-packing-slip-form').submit(function(e) {
    /*
    var data = $('#packing_slips_')[0];
    var file = data.files[0];

    var context = $(tmpl('template-upload', file));
    $('#js-packing-slip-info-zone').append(context);
    context.data('file-data', data);

    data.formData = {
      script_container_id: context.attr('id')
    };

    */
    $('#packingSlipModal').modal('hide');
  });
});
