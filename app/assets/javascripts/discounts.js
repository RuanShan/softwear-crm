$(function() {
  $(document).on('click', '.in-store-credit-search-button', function(event) {
    event.preventDefault();

    data = {
      q: $(this).closest('div').find('.in-store-credit-search').val()
    }
    $('#in-store-credit-spot').children().each(function() {
      if (data.exclude === undefined) data.exclude = [];
      data.exclude.push($(this).data('id'));
    });

    $.ajax({
      url: Routes.search_in_store_credits_path(),
      dataType: 'script',
      data: data
    });
  });
});
