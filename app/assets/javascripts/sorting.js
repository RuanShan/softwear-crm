function initializeSort() {
  $('th.sort').click(function() {
    var sortBy   = $(this).data('sort-by');
    var ordering = $(this).data('ordering');

    if (sortBy == null) return;
    sortBy = encodeURIComponent(sortBy);
    if (ordering != null)
      ordering = encodeURIComponent(ordering);

    var url = decodeURI(window.location.href);
    url = url.replace(/\#.+/, '').replace(/[&\?]ordering=\w+/, '');

    if (/[&\?]sort=/.test(url)) {
      url = url.replace(/sort=\w+/, 'sort='+sortBy);
    }
    else {
      if (/\?/.test(url))
        url += '&sort='+sortBy;
      else
        url += '?sort='+sortBy;
    }
    if (ordering != null) url += '&ordering='+ordering;

    $.ajax({
      url: url,
      dataType: 'script',
      success: function() { history.pushState(null, null, encodeURI(url)); }
    });
  });
}

$(initializeSort);
