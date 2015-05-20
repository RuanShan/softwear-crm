function minimizeDock(e) {
  $('#dock-body').hide();
  $('#minimize-dock').hide();
  $('#maximize-dock').show();
  localStorage.dockMinimized = true;
  if (e)
    e.preventDefault();
}
function maximizeDock(e) {
  $('#dock-body').show();
  $('#minimize-dock').show();
  $('#maximize-dock').hide();


  localStorage.dockMinimized = false;
  if (e)
    e.preventDefault();
}

function initDockTabs() {
  $('.dock-tab').on('click.docktabs', function(e) {
    var qrId = $(this).data('qr-id');
    localStorage.dockTab = qrId;
  });

  if (localStorage.dockTab)
    $('#dock-tab-for-'+localStorage.dockTab).tab('show');
  else if ($('.dock-tab').length == 1)
    $('.dock-tab').tab('show');
}

$(function() {
  if (localStorage.dockMinimized)
    minimizeDock();
  else
    maximizeDock();

  initDockTabs();

  $('#minimize-dock').click(minimizeDock);
  $('#maximize-dock').click(maximizeDock);
});
