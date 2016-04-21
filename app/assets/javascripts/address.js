function showAddressFields() {
  $('.individual-address-fields').removeClass('hidden');
  $('.address_autocomplete_container').addClass('hidden');
  $('#toggle-address-fields').text('hide address fields');
}

function hideAddressFields() {
  $('.individual-address-fields').addClass('hidden');
  $('.address_autocomplete_container').removeClass('hidden');
  $('#toggle-address-fields').text('show address fields');
}

function toggleAddressFields() {
  if ($('.individual-address-fields').hasClass('hidden'))
    showAddressFields();
  else
    hideAddressFields();
}

function initAddressAutocomplete() {
  var autocompleteField = $('#address_autocomplete');
  if (autocompleteField.length === 0) return;
  try { google.maps.places.Autocomplete; }
  catch(e) { return; }

  autocompleteField.on('input:text', function(event) {
    if (event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });

  hideAddressFields();

  var autocomplete = new google.maps.places.Autocomplete(
    autocompleteField[0], { types: ['geocode'] }
  );

  autocomplete.addListener('place_changed', function() {
    var place = autocomplete.getPlace();

    $('.address-name').val(place.name);

    for (var i = 0; i < place.address_components.length; i++) {
      var component = place.address_components[i];

      for (var j = 0; j < component.types.length; j++) {
        var type = component.types[j];
        var matchingInputs = $(".address-"+type);

        matchingInputs.each(function() {
          var name = $(this).data('name');

          if (name == undefined) name = 'long_name';
          else                   name = name+"_name";

          $(this).val(component[name]);
        });
      }
    }
  });
}
