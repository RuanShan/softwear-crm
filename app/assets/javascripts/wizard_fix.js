$(function() {
  var easyWizardSections = $('#easyWizard section.step');
  easyWizardSections.each(function(i) {
    var section = $(this)
    var sectionInputs = section.find('input');

    $(sectionInputs[0]).keydown(function(e) {
      var prevIndex = i - 1;

      if (e.which === 9 && e.shiftKey) {
        $('button.prev').click();
        var prevSection = easyWizardSections[prevIndex];
        if (prevSection) {
          setTimeout(function() {
            var inputs = $(prevSection).find('input');
            $(inputs[inputs.length - 1]).focus();
          }, 500);
        }
        return false;
      }
    });

    $(sectionInputs[sectionInputs.length - 1]).keydown(function(e) {
      var nextIndex = i + 1;

      if (e.which === 9 && !e.shiftKey) {
        $('button.next').click();
        var nextSection = easyWizardSections[nextIndex];
        if (nextSection) {
          setTimeout(function() {
            $($(nextSection).find('input')[0]).focus();
          }, 500);
        }
        return false;
      }
    });

  });

  $('#easyWizard').keydown(function(e) {
    if (e.which === 13) {
      $('#easyWizard').submit();
      return false;
    }
  });
});
