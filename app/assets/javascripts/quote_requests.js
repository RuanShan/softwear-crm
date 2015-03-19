$(document).ready(function(){
    $('#start_time').datetimepicker();
    $('#end_time').datetimepicker();

    var qrStatusEditable = $('#quote-request-status span.editable');
    var qrStatusSpan = $('span[data-name="status"]');

    qrStatusSpan.editable('option', 'validate',
      function(value) {
        if (value == 'could_not_quote') {
          if ($('#qr-reason-text').val() == '') {
            return 'You must enter a reason for being unable to quote.';
          } else {
            var succeeded = false;

            // This is an unfortunate hack and should probably be refactored.
            // The 'editable' plugin does not accomodate the reason text box
            // functionality we want.
            $.ajax({
              method: 'PUT',
              url: qrStatusSpan.data('url'),

              data: { quote_request: { reason: $('#qr-reason-text').val() } },
              dataType: 'json',

              success: function() { succeeded = true; },

              async: false
            });
            setTimeout(function() {
              $('.modal-backdrop').remove();
            }, 1000);

            if (succeeded) {
            } else {
              return 'Error processing request';
            }
          }
        }
        else {
          $('#quote-request-reason-div').remove();
        }
      }
    );


    qrStatusEditable.on('click.qrreason', function() {
      $('#quote-request-status .editable-popup')
        .find('form')
        .find('.control-group')
        .append(
          "<div id='quote-request-reason' style='display: none;'>" +
            "<div><label>Reason *</label></div>" +
            "<textarea id='qr-reason-text' class='form-control input-sm'></textarea>" +
          "</div>"
        );

      $('#quote-request-status .editable-popup')
        .find('select')
        .change(function() {
          if ($(this).val() == 'could_not_quote')
            $('#quote-request-reason').show();
          else
            $('#quote-request-reason').hide();
        });

    });
  }
);
