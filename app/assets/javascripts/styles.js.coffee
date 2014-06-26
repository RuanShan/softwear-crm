$ ->
  # see https://github.com/rorlab/summernote-rails for examples
  summer_note = $('#style_description')
  summer_note.summernote
  summer_note.code summer_note.val()
  summer_note.closest('form').submit ->
    summer_note.val summer_note.code()
    true


