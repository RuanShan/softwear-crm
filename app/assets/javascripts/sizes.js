$(document).ready(function() {
    // Return a helper with preserved width of cells
    var fixHelper = function(e, ui) {
        ui.children().each(function() {
            $(this).width($(this).width());
        });
        return ui;
    };

    $("#sizes_list tbody").sortable({helper: fixHelper}).disableSelection();
});
