$(window).load ->
  $('.js-clear-btn').click ->
    document.getElementById("js_search").value = "";

  deleteSearchQuery = ->
    $this = $(this)
    queryId = $this.data('query-id')
    confirmModal "Delete saved search query?", ->
      ajax = $.ajax
        type: 'DELETE'
        url: Routes.search_query_path(queryId)
        dataType: 'json'

      ajax.done (response) ->
        if response.result == 'success'
          $select = $this.data('search-select')
          $select.find("option[value='#{queryId}']").remove()
          $("##{$select.data('go')}").find('.gobtn').remove()
          successModal "Successfully deleted saved search query!"
        else
          errorModal "Somehow failed to delete saved search query!"

      ajax.fail (jqXHR, textStatus) ->
        errorModal "Something went wrong with the server, or it's unreachable."

  $('.search-query-select').change ->
    $this = $(this)

    goSpot = ->
      if $this.data('go')
        $("##{$this.data('go')}")
      else
        $this.parent()

    if $this.val() is 'nil'
      goSpot().find('.gobtn').remove()
    else
      if goSpot().find('.gobtn').length == 0
        $btn = $ "<button type='button' class='btn btn-default gobtn'>GO</button>"
        $btn.click -> $this.parent().submit()
        $delete = $ "
        <button type='button' class='btn btn-danger gobtn del'
          data-query-id='#{$this.val()}'>X</button>"
        $delete.click deleteSearchQuery
        $delete.data 'search-select', $this
        goSpot().append $btn
        goSpot().append $delete
      else
        goSpot().find('.gobtn.del').data 'query-id', $this.val()

  $('.search-query-select').keydown (key) ->
    if key.which is 13
      $(this).parent().submit()

  $('.btn-search-save').click ->
    $this = $(this)
    $form = null
    if $this.parent('form').length > 0
      $form = $this.parent()
    else
      $form = $this.parentsUntil('form').parent()

    $enterName = $ "
    <label for='query_name'>Enter name for new query</label>
    <input type='text' id='query_name_input' class='form-control' name='query_name'></input>
    "
    
    setupContentModal ($modal) ->
      after 500, ->
        $modal.find('#query_name_input').keyup (key) ->
          if key.which is 13
            $('#modal-confirm-btn').trigger $.Event('click')

    confirmModal $enterName, ->
      $queryNameField = $('#query_name_input')
      name = $queryNameField.val()
      
      $form.prop 'action', Routes.search_queries_path()
      $form.prop 'method', 'POST'

      $form.find('.query_name').removeProp 'disabled'
      $form.find('.user_id').removeProp 'disabled'
      $form.find('.target_path').removeProp 'disabled'
      
      $form.find('.query_name').val name
      $form.find('.target_path').val document.URL

      $form.submit()
