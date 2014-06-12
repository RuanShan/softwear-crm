$(document).ready(function(){
    $('#order_artwork_requests_imprint_method').change(function (e) {
        if($(this).find(":selected").attr('value') != null) {
            $.ajax({
                url: "/configuration/imprint_methods/" + $(this).find(":selected").attr('value'),
                dataType: 'script'
            })
        }
    });
});
