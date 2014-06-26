#@idleTimeoutMs = 600000 # 10 minutes
#@idleWarningSec = 60    # 1 minute
#$(window).load ->
#  if $('#contentModal').length == 0 then return
#
#  $('#contentModal .modal-title').html 'Warning: inactive!'
#  set_countdown_timer = ->
#    $('#contentModal .modal-body').html "You will be temporarily logged out in #{count} seconds"
#    count--
#    $('#contentModal').modal 'show'
#    if count < 0
#      clearInterval inter
#      on_timeout()
#
#  count = idleWarningSec
#  inter = null
#
#  timer = $.timer ->
#    timer.stop()
#    count = idleWarningSec
#    inter = null
#    inter = setInterval set_countdown_timer, 1000
#
#  cancel = ->
#    timer.stop()
#    if inter then clearInterval inter
#    $("#contentModal").modal 'hide'
#  begin = ->
#    cancel()
#    timer.set { time: idleTimeoutMs, autostart: true }
#
#  begin()
#  $(window).mouseup begin
#  $(window).keypress begin
#
#  on_timeout = ->
#    form = $('<form/>', action: '/users/lock', method: 'get')
#    form.append $('<input/>', type: 'submit', name: 'location', value: document.URL, id: 'lock_go')
#    $('body').append form
#    $('#lock_go').click()
