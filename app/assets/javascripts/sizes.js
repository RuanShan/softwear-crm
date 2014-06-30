$(document).ready(function() {
    // Return a helper with preserved width of cells
    var fixHelper = function(e, ui) {
        ui.children().each(function() {
            $(this).width($(this).width());
        });
        return ui;
    };
    var sel = "#sizes_list tbody";
    $(sel).sortable({
        helper: fixHelper,
        update: function(event, ui) {
            var itm_arr = $(sel).sortable('toArray');
            console.log(itm_arr);
            var pobj = {categories: itm_arr};
            $.post("/imprintables/sizes/update_size_order", pobj);
        }
    });
});
