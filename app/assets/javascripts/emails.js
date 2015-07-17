function freshdeskCopyBtn(event) {
  event.preventDefault();

  var serialized = $('form.new_email').serializeArray();
  var data = {email: {}};

  serialized.forEach(function(item) {
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
    url: Routes.email_freshdesk_path(),

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

html_editor_settings = {
    nameSpace:       "html", // Useful to prevent multi-instances CSS conflict
    onShiftEnter:    {keepDefault:false},
    onCtrlEnter:     {keepDefault:false},
    onTab:           {keepDefault:false, openWith:'  '}
    //,
    //markupSet:  [
    //    {name:'Heading 1', key:'1', openWith:'<h1(!( class="[![Class]!]")!)>', closeWith:'</h1>'},
    //    {name:'Heading 2', key:'2', openWith:'<h2(!( class="[![Class]!]")!)>', closeWith:'</h2>'},
    //    {name:'Heading 3', key:'3', openWith:'<h3(!( class="[![Class]!]")!)>', closeWith:'</h3>'},
    //    {name:'Heading 4', key:'4', openWith:'<h4(!( class="[![Class]!]")!)>', closeWith:'</h4>'},
    //    {name:'Heading 5', key:'5', openWith:'<h5(!( class="[![Class]!]")!)>', closeWith:'</h5>'},
    //    {name:'Heading 6', key:'6', openWith:'<h6(!( class="[![Class]!]")!)>', closeWith:'</h6>'},
    //    {name:'Paragraph', openWith:'<p(!( class="[![Class]!]")!)>', closeWith:'</p>'  },
    //    {separator:'---------------' },
    //    {name:'Bold', key:'B', openWith:'<strong>', closeWith:'</strong>' },
    //    {name:'Italic', key:'I', openWith:'<em>', closeWith:'</em>'  },
    //    {name:'Stroke through', key:'S', openWith:'<del>', closeWith:'</del>' },
    //    {separator:'---------------' },
    //    {name:'Ul', openWith:'<ul>\n', closeWith:'</ul>\n' },
    //    {name:'Ol', openWith:'<ol>\n', closeWith:'</ol>\n' },
    //    {name:'Li', openWith:'<li>', closeWith:'</li>' },
    //    {separator:'---------------' },
    //    {name:'Picture', key:'P', replaceWith:'<img src="[![Source:!:http://]!]" alt="[![Alternative text]!]" />' },
    //    {name:'Link', key:'L', openWith:'<a href="[![Link:!:http://]!]"(!( title="[![Title]!]")!)>', closeWith:'</a>', placeHolder:'Your text to link...' },
    //    {separator:'---------------' },
    //    {name:'Clean', replaceWith:function(h) { return h.selection.replace(/<(.*?)>/g, "") } },
    //    {name:'Preview', call:'preview', className:'preview' }
    //]
}
