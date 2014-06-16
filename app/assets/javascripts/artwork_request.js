$(document).ready(function() {
    var jobArray, jobs;
    $("#order_artwork_requests_imprint_method").change(function(e) {
        if ($(this).find(":selected").attr("value") != null) {
            $.ajax({
                url: $(this).data('url') + '/' +  $(this).find(":selected").attr('value'),
                dataType: "script"
            });
        }
    });
    jQuery.fn.exists = function() {
        return this.length > 0;
    };

    if ($("#artwork-show").exists()) {

    }





    if ($("#jobstokenfield").exists()) {
        jobs = $("#jobstokenfield").data("jobs");
        jobArray = [];
        $.each(jobs, function(i, e) {
            $.each(e, function(key, val) {
                jobArray.push(val);
            });
        });
        $("#jobstokenfield").tokenfield({
            autocomplete: {
                source: jobArray,
                delay: 100
            },
            showAutocompleteOnFocus: true
        });
    }
});
