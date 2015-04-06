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

$(function() {
  if (localStorage.dockMinimized)
    minimizeDock();
  else
    maximizeDock();

  $('#minimize-dock').click(minimizeDock);
  $('#maximize-dock').click(maximizeDock);
});
