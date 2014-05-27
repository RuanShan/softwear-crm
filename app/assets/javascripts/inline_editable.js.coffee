$(window).load ->
	fields = {}

	# TODO okay... the idea is to have knowledge of every other
	# field. 

	# Actually that might be a bad idea.

	# Running an AJAX to job#update for each individual field 
	# may in fact be best.

	# So, send an ajax with params = { 
	# 	id: self.resourceId, 
	# 	self.field => self.content
	# }
	# 
	# On a timer, of course, so the server doesn't get spammed!
	createObj = ($this) ->
		resourceName: $this.attr('resource-name'),
		resourceId: $this.attr('resource-id'),
		field: $this.attr('resource-method'),


	$('.inline-field').each (index) ->
		self = createObj($(this))

		fields[self.resourceName] ?= {}
		fields[self.resourceName][self.resourceId] ?= {}
		fields[self.resourceName][self.resourceId][self.field] = $(this).contents()

		$(this).keyup ->
			self.content = $(this).text()

			console.log "Inline changed! resource: #{self.resourceName}, 
						id: #{self.resourceId}, 
						field: #{self.field},
						content: #{self.content}"


