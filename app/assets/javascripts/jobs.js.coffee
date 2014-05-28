@deleteJob = (jobId) ->
	$this = $(".delete-job-button[for='#{jobId}']")
	$this.attr 'disabled', 'disabled'
	setTimeout (-> $this.removeAttr 'disabled'), 30000

	ajax = $.ajax
		type: 'DELETE',
		url: "/jobs/#{jobId}"

	ajax.done (response) ->
		if response.result == 'success'
			$("#job-#{jobId}").fadeOut 1000
		else if response.result == 'failure'
			alert "Couldn't delete the job for some reason!"
		else
			console.log 'No idea what happened'

	ajax.fail (jqXHR, textStatus) ->
		alert "Something went wrong with the server and
				the new job couldn't be deleted for some reason."

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
				msg = "Error creating new job!:\n"
				msg += "#{error}\n" for error in response.errors
				alert msg
			else
				$('#jobs').children().last().before $(response)

				$('.scroll-y').scrollTo $('h3.job-title').last(),
					duration: 1000,
					offsetTop: 100

				refresh_inlines()

		ajax.fail (jqXHR, textStatus) ->
			alert "Something went wrong with the server and
						 the new job couldn't be created."
