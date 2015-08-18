module SimulateDragSortable
  def simulate_drag_sortable_on(page)
    return if @simulating_drag_sortable

    @simulating_drag_sortable = true
    page.execute_script(
      File.read(
        File.expand_path("../../../vendor/assets/javascripts/jquery/jquery.simulate.drag-sortable.js", __FILE__)
      )
    )
  end

  def simulate_drag_sortable(selector, options = {})
    unless @simulating_drag_sortable
      raise "You must call `simulate_drag_sortable_on page` before simulating drag-sortable"
    end

    page.execute_script %(
      $(document).ready(function() {
        $('#{selector}').simulateDragSortable(#{options.to_json});
      });
    )
  end
end
