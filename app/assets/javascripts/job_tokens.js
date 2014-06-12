$(function () {
    $('#jobstokenfield').tokenfield({
        autocomplete: {
            source: ['Job 1', 'Job 2', 'Job 3'],
            delay: 100
        },
        showAutocompleteOnFocus: true
    });
});


