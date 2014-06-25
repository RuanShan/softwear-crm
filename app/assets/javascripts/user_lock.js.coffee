@idleTimeoutMs = 600000 # 10 minutes
@idleWarningSec = 60    # 1 minute
$(window).load ->
  if $('#timeoutModal').length == 0 then return

  set_countdown_timer = ->
    $('#timeoutModal .modal-body').html "You will be temporarily logged out in #{count} seconds"
    count--
    $('#timeoutModal').modal 'show'
    if count < 0
      clearInterval inter
      on_timeout()

  count = idleWarningSec
  inter = null
  warning = false
  
  timer = $.timer ->
    timer.stop()
    count = idleWarningSec
    $('#timeoutModal .modal-title').html 'Warning: inactive!'
    inter = setInterval set_countdown_timer, 1000
    warning = true

  cancel = ->
    timer.stop()
    clearInterval inter if inter
    $("#timeoutModal").modal 'hide' if warning
    warning = false
  begin = ->
    cancel()
    timer.set { time: idleTimeoutMs, autostart: true }

  begin()
  $(window).mouseup begin
  $(window).keypress begin
  $('#timeoutModal').on 'hidden.bs.modal', begin

  on_timeout = ->
    form = $('<form/>', action: '/users/lock', method: 'get')
    form.append $('<input/>', type: 'submit', name: 'location', value: document.URL, id: 'lock_go')
    $('body').append form
    $('#lock_go').click()
