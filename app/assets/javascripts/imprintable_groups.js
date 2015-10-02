$(function() {
  if ($('#imprintable-groups-list').length) {
    new List(
      'imprintable-groups-list',
      {
        valueNames: ['imprintable-group'],
        plugins:    [ListFuzzySearch()]
      }
    );

    $('#imprintable_groups_table_body .imprintable-group').css('cursor', 'pointer');
    $('#imprintable_groups_table_body .imprintable-group').click(function() {
      $.ajax({
        url: Routes.imprintable_group_path($(this).data('id')),
        dataType: 'script',
        failure: function() {
          alert('Network error - sorry!');
        }
      });
    });
  }
});
