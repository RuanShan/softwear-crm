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

	capitalize = (str) -> str.charAt(0).toUpperCase() + str.substr(1)

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
					# Clean up error stuff if present
					$(".error[for='#{self.getErrorFor()}']").remove()
					$this.unwrap() if $this.parent().attr('class') == 'field_with_errors'
					$(".error-modal[for='#{self.getErrorFor()}']").remove()

					if response.result == 'success'
						console.log "Successfully updated #{self.resourceName}[#{self.field}]"
					else if response.result == 'failure'
						console.log "Error updating #{self.resourceName}[#{self.field}]"
						console.log response.modal

						# Add error stuff
						$this.before $('<div/>',
							class: 'error', 
							for:   self.getErrorFor()
						)
						container = $(".error[for='#{self.getErrorFor()}']")
						$this.wrap $("<div/>", class: 'field_with_errors')
						$('body').children().last().after $("<div/>", 
							class: 'error-modal', 
							for: self.getErrorFor())
						$(".error-modal[for='#{self.getErrorFor()}']").append $(response.modal)
						$('#errorsModal').modal 'show'

						for field, fieldErrors of response.errors
							for error in fieldErrors
								container.append $('<p/>',
									class: 'text-danger'
									text:  "#{capitalize field} #{error}"
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
	