$(document).ready ->
  fixHelper = (event, unorderedListElement) ->
    unorderedListElement.children().each ->
      $(this).width $(this).width()
    unorderedListElement

  selector = "#js-sizes-list tbody"

  $(selector).sortable
    helper: fixHelper
    update: (event, unorderedListElement) ->
      item_array = $(selector).sortable("toArray")
      plain_object = categories: item_array
      $.post "/imprintables/sizes/update_size_order", plain_object