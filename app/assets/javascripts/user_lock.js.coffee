$(window).load ->
  if $('#contentModal').length == 0 then return

  $('#contentModal .modal-title').html 'Warning: inactive!'
  set_countdown_timer = ->
    $('#contentModal .modal-body').html "You will be temporarily logged out in #{count} seconds"
    count--
    $('#contentModal').modal 'show'
    if count < 0
      clearInterval inter
      on_timeout()

  count = 60
  inter = null
  
  timer = $.timer ->
    timer.stop()
    count = 60
    inter = null
    inter = setInterval set_countdown_timer, 1000

  begin = ->
    timer.set { time: 5000, autostart: true }
  cancel = ->
    timer.stop()
    if inter then clearInterval inter
    $("#contentModal").modal 'hide'

  begin()
  $(window).mouseup ->
    cancel()
    begin()

  on_timeout = ->
    alert 'bang'
