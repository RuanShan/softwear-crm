#TODO comment format, review for possible refactor

# Any span with the inline-field class will be editable without
# the text field background, and updated automatically via AJAX. 
# There is a helper method for inline fields in the LancengFormBuilder.

@registeredInlines = []

@inlineEditableCallbacks = []

# Milliseconds to wait after the user types a key before updating
# the database
updateDelay = 1000

# If you update the DOM with new inline fields, call this method.
@refresh_inlines = ->
  fields = {}
  timers = {}

  # Utility functions
  capitalize = (str) -> str.charAt(0).toUpperCase() + str.substr(1)

  isWhitespace = (str) -> /\s+/.test str
  trimRight = (str) -> str.replace /\s+$/, ''
  singleLeadingSpace = (str) -> str.length > 1 && isWhitespace(str.charAt(0)) && !isWhitespace(str.charAt(1))

  createObj = ($this) ->
    resourceName:   $this.attr('resource-name'),
    resourcePlural: $this.attr('resource-plural'),
    resourceId:     $this.attr('resource-id'),
    field:          $this.attr('resource-method'),
    content:        $this.text(),
    getParamName: (-> "#{this.resourceName}[#{this.field}]"),
    getErrorFor:  (-> "#{this.resourceName}[#{this.resourceId}][#{this.field}]")

  $('.inline-field').each (index) ->
    $this = $(this)
    self = createObj($this)
    if $.inArray(self.getErrorFor(), registeredInlines) == -1
      registeredInlines.push self.getErrorFor()

      # If the user times it just right, and edits an invalid field immediately after
      # the AJAX request is sent (before response is received), the error will pop up
      # and interrupt their typing. This will combat that.
      changedSinceAjax = false

      # Create a timer associated with this particular field
      timer = $.timer -> 
        timer.stop()

        # We want to remove certain whitespaces from the field.
        # Unfortunately, the caret is reset if we do this while
        # the user might be editing so we make sure we only
        # clear the whitespace once the field is no longer in 
        # focus.
        if inter != null
          clearInterval inter
          inter = null

        # If there is a single space in the beginning, or any trailing whitespace, kill them!
        dirty = false
        if singleLeadingSpace(self.content)
          self.content = self.content.substr(1)
          dirty = true
        if trimRight(self.content) != self.content
          self.content = self.content.trimRight()
          dirty = true

        if dirty
          # But not when the user could be making changes
          if $this.is ':focus'
            inter = setInterval (->
              if !$this.is ':focus'
                $this.text self.content
                clearInterval inter), 1000
          else
            $this.text self.content
        # Okay, done with that (phew)

        params = {}
        params[self.getParamName()] = self.content

        ajax = $.ajax
          type: 'PUT',
          url: "/#{self.resourcePlural}/#{self.resourceId}", 
          data: params,
          dataType: 'json'
        changedSinceAjax = false

        ajax.done (response) ->
          return if changedSinceAjax

          # Clean up error stuff if present
          errorDiv = $(".error[for='#{self.getErrorFor()}']")
          if errorDiv.length > 0
            errorDiv.remove()
            $this.unwrap() if $this.parent().attr('class') == 'field_with_errors'
            $(".error-modal[for='#{self.getErrorFor()}']").remove()
            $this.focus()

          if response.result is 'success'
            console.log "Successfully updated #{self.resourceName}[#{self.field}]"
            callback(true) for callback in inlineEditableCallbacks
          else if response.result is 'failure'
            console.log "Error updating #{self.resourceName}[#{self.field}]"
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
            
            callback(false) for callback in inlineEditableCallbacks

        ajax.fail (jqXHR, textStatus) ->
          alert "Something went wrong with the server and 
               your changes couldn't be saved."

      $(this).keyup ->
        self.content = $(this).text()
        # Make sure the field doesn't end up empty (else it disappears)
        $(this).html '&nbsp' if self.content.length is 0

        # Set the timer so that if there is no keypress after
        # some time, we update the database with the new data.
        timer.stop()
        timer.set {time: updateDelay, autostart: true}

        # Flag this in case we happened to have an incoming response
        changedSinceAjax = true


$(window).load refresh_inlines
  