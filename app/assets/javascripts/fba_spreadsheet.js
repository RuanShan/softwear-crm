$(function() {
  if ($('.waiting-for-spreadsheet').length == 0) return;
  var id = $('#js-fba-spreadsheet-id').data('id');
  if (id == null || id.length == 0) return;

  window.noSpinner = true;

  window.checkSpreadsheetStatus = function() {
    $('#loading').show();
    $.ajax({
      type: 'GET',
      url:  Routes.fba_spreadsheet_upload_path(id),
      dataType: 'script'
    });
  };
  setTimeout(window.checkSpreadsheetStatus, 1000);
});
