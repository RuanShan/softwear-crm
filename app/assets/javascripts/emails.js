$(function() {
  $('#freshdesk-copypaste-btn').click(function(event) {
    event.preventDefault();

    var quoteId = $(this).data('quote-id');
    var serialized = $('form.new_email').serializeArray();
    var data = {email: {}};

    serialized.forEach(function(item) {
      if (item.name == 'quote_id') {
        data.quote_id = item.value;
        return;
      }

      var name = item.name.match(/\[\w+\]/g);
      if (!name) return;
      name = name[0];
      var brackets = /[\[\]]/g;
      if (!name.match(brackets)) return;
      name = name.replace(brackets, '');

      data.email[name] = item.value;
    });
    data.email.body = $('#email_body').code();

    $.ajax({
      method: 'POST',
      url: Routes.freshdesk_quote_emails_path(quoteId),

      data: data,
      dataType: 'script'
    });
  });
});

function SelectText(element) {
  var doc  = document,
      text = doc.getElementById(element),
      range, selection
  ;    
  if (doc.body.createTextRange) {
    range = document.body.createTextRange();
    range.moveToElementText(text);
    range.select();
  } else if (window.getSelection) {
    selection = window.getSelection();        
    range = document.createRange();
    range.selectNodeContents(text);
    selection.removeAllRanges();
    selection.addRange(range);
  }
}
