$(window).load ->
	$('#new-job-button').click ->
		self = $(this)
		self.attr 'disabled', 'disabled'
		setTimeout (-> self.removeAttr 'disabled'), 1000
