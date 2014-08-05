@setNewProofSelect = ->
  $(".proof-status-select").hide()
  $(".proof-status-select").val "Pending"

@showProofSelect = ->
  $(".proof-status-select").show()

@initializeProofSummernote = ->
  #TODO remove the summernote crap that's in global and call that in js.erb
  $(".summernote").summernote
    height: 300
    toolbar:[
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
      ['fontsize', ['fontsize']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['height', ['height']],
      ['table', ['table']],
#      ['insert', ['link']],
      ['view', ['fullscreen', 'codeview']],
#      ['help', ['help']]
    ]
  sHTML = $('.summernote').val();
  $('.summernote').code(sHTML);



