$(window).load ->
	$('#new-job-button').click ->
		self = $(this)
		self.attr 'disabled', 'disabled'
		setTimeout (-> self.removeAttr 'disabled'), 1000

		params = {}
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

				$('.scroll-y').scrollTo $('h3.job-title').last(),
					duration: 1000,
					offsetTop: 100

				refresh_inlines()

		ajax.fail (jqXHR, textStatus) ->
			alert "Something went wrong with the server and
						 the new job couldn't be created"
