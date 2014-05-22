$(window).load ->
	$('#contentModal .modal-title').html 'Warning: inactive!'
	set_countdown_timer = ->
		$('#contentModal .modal-body').html "You will be temporarily logged out in #{count--} seconds"
		$('#contentModal').modal 'show'
	count = 60
	inter = null
	
	timer = $.timer ->
		timer.stop()
		count = 60
		inter = null
		countdownfunc = -> set_countdown_timer(); inter = setInterval(countdownfunc, 1000);
		countdownfunc()

	begin = ->
		timer.set { time: 1000, autostart: true }
	cancel = ->
		timer.stop()
		if inter then clearInterval inter
		$("contentModal").modal 'hide'

	begin()
	$(window).mouseup ->
		cancel()
		begin()
