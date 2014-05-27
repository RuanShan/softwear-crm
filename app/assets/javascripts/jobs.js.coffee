$(window).load ->
	$('#new-job-button').click ->
		self = $(this)
		self.attr 'disabled', 'disabled'
		setTimeout (-> self.removeAttr 'disabled'), 1000

		params = {}
		params['job[name]'] = 'Job Name'
		params['job[description]'] = 'Job description'
		ajax = $.ajax
			type: 'POST',
			url: "/jobs", 
			data: params

		ajax.done (response) ->
			if typeof response is 'object'
				alert "Error creating new job!"
			else
				$('#new-job-button').before().parent().parent().before $(response)
				refresh_inlines()

		ajax.fail (jqXHR, textStatus) ->
			alert "Something went wrong with the server and
						 a new job couldn't be created"
