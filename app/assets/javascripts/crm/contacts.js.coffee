$ ->
  $('.email-primary').change ->
    if this.checked
      $(".email-primary:not(#"+$(this).id()+")").removeAttr('checked')

  $('.phone-primary').change ->
    if this.checked
      $(".phone-primary:not(#"+$(this).id()+")").removeAttr('checked')