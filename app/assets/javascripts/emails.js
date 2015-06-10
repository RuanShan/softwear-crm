function freshdeskCopyBtn(event) {
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

  $.ajax({
    method: 'POST',
    url: Routes.freshdesk_quote_emails_path(quoteId),

    data: data,
    dataType: 'script'
  });
}

$(function() {
  $('#email-template-select').change(function() {
    if ($(this).val() != '') {
      $.ajax({
        method: 'GET',
        url: "/" + $(this).attr('data-model') + "s/" + $(this).attr('data-record-id') + '/emails/new',
        data: {
          email_template_id: $(this).val(),
          freshdesk: $(this).data('freshdesk')
        },
        dataType: 'script'
      });
    }
  });

  $('#freshdesk-copypaste-btn').click(freshdeskCopyBtn);
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
