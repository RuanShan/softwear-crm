# Any span with the inline-field class will be editable without
# the text field background, and updated automatically via AJAX. 
# There is a helper method for inline fields in the LancengFormBuilder.

@registeredInlines = []
# If you update the DOM with new inline fields, call this method.
@refresh_inlines = ->
	fields = {}
	timers = {}
	# Milliseconds to wait after the user types a key before updating
	# the database
	updateDelay = 1000

	createObj = ($this) ->
		resourceName: $this.attr('resource-name'),
		resourceId:   $this.attr('resource-id'),
		field:        $this.attr('resource-method'),
		content:      $this.text()
		getParamName: (-> "#{this.resourceName}[#{this.field}]"),
		getErrorFor:  (-> "#{this.resourceName}[#{this.resourceId}][#{this.field}]")

	$('.inline-field').each (index) ->
		$this = $(this)
		self = createObj($this)
		if $.inArray(self.getErrorFor(), registeredInlines) == -1
			registeredInlines.push self.getErrorFor()

			# Create a timer associated with this particular field
			timer = $.timer -> 
				timer.stop()
				params = {}
				params[self.getParamName()] = self.content

				ajax = $.ajax
					type: 'PUT',
					url: "/jobs/#{self.resourceId}", 
					data: params,
					dataType: 'json'

				ajax.done (response) ->
					if response.result == 'success'
						console.log "Successfully updated #{self.resourceName}[#{self.field}]"
						$(".error-container[for='#{self.getErrorFor()}']").remove()
					else if response.result == 'failure'
						container = $this.before $('<div/>',
							class: 'error-container', 
							for:   self.getErrorFor()
						)
						# probably won't work; errors.messages probably requires field keys
						for error in response.errors
							container.append $('<p/>',
								class: 'text-danger'
								text:  error
							)

				ajax.fail (jqXHR, textStatus) ->
					alert "Something went wrong with the server and 
						   your changes couldn't be saved."

			$(this).keyup ->
				self.content = $(this).text()

				# Set the timer so that if there is no keypress after
				# some time, we update the database with the new data.
				timer.stop()
				timer.set {time: updateDelay, autostart: true}


$(window).load refresh_inlines
	