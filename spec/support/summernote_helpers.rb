def fill_in_summernote(item, options)
  #page.execute_script('$("#foo_description_raw").tinymce().setContent("Pants are pretty sweet.")')
  page.execute_script("$('#{item}').val('#{options[:with]}')")
  page.execute_script("$('#{item}').code($('#{item}').val())")
end
