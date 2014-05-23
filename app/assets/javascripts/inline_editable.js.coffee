$(window).load ->
	$('.inline-field').each (index) ->
		$(this).keypress ->
			console.log "Inline changed! resource: #{$(this).attr 'resource-name'}, 
						id: #{$(this).attr 'resource-id'}, 
						field: #{$(this).attr 'resource-method'}"