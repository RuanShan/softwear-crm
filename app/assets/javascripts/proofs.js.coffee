@setNewProofSelect = ->
  $(".proof-status-select").hide()
  $(".proof-status-select").val "Pending"

@showProofSelect = ->
  $(".proof-status-select").show()

@styleCheckboxes = ->
  $("input").iCheck(
    checkboxClass: "icheckbox_minimal-grey proof-checkbox"
    radioClass: "iradio_minimal-grey"
    increaseArea: "20%"
  )
@initializeProofSummernote = ->
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



