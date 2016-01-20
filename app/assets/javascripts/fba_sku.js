$(window).load(function() {
  if ($('.fba-skus').length === 0) return;

  console.log('doing it');

  var replaceAt = function(str, index, character) {
    return str.substr(0, index) + character + str.substr(index+character.length);
  };
  var variant_fields = ['fba-sku-brand', 'fba-sku-style', 'fba-sku-color', 'fba-sku-size'];

  var initializeForm = function(fields, isNewEntry) {
    var hideIfBlank = function(element) {
      var len = element.find('option').length;
      if (len === 1 || len === 0) element.next().hide();
    }

    var arrayDataFrom = function(select) {
      arr = [ { id: '', text: '' } ];
      select.find('option').each(function() {
        arr.push({
          id: $(this).val(),
          text: $(this).text()
        });
      });
      return arr;
    }

    var id = fields.find('.fba-sku-sku').attr('name')

    if (isNewEntry && $('.fba-sku-fields').length > 1) {
      var allFields = $('.fba-sku-fields');
      var previousFields = $(allFields[allFields.length - 2]);

      fields.find('.fba-sku-brand').val(previousFields.find('.fba-sku-brand').val()).trigger('change');

      fields.find('.fba-sku-style option').remove();
      fields.find('.fba-sku-style').select2({ data: arrayDataFrom(previousFields.find('.fba-sku-style')) });
      fields.find('.fba-sku-style').val(previousFields.find('.fba-sku-style').val()).trigger('change');

      fields.find('.fba-sku-color option').remove();
      fields.find('.fba-sku-color').select2({ data: arrayDataFrom(previousFields.find('.fba-sku-color')) });
      fields.find('.fba-sku-color').val(previousFields.find('.fba-sku-color').val()).trigger('change');

      fields.find('.fba-sku-size option').remove();
      fields.find('.fba-sku-size').select2({ data: arrayDataFrom(previousFields.find('.fba-sku-size')) });
      fields.find('.fba-sku-size').val('').trigger('change');

      var prevSku = previousFields.find('.fba-sku-sku').val();
      if (prevSku.match(/0-\w+-\d{10}/)) {
        var newSku = replaceAt(prevSku, prevSku.length - 4, '_');
        var newSku = replaceAt(newSku,  newSku.length  - 5, '_');
        fields.find('.fba-sku-sku').val(newSku);
      }
      else
        fields.find('.fba-sku-sku').val(prevSku);
    }

    hideIfBlank(fields.find('.fba-sku-style'));
    hideIfBlank(fields.find('.fba-sku-color'));
    hideIfBlank(fields.find('.fba-sku-size'));

    fields.find('.fba-sku-brand').on('select2:select', function() {
      $.ajax({
        type: 'GET',
        url:  Routes.variant_fields_fba_products_path(),
        data: {
          entries: [{
            id: id,
            brand_id: $(this).val()
          }]
        },
        dataType: 'script'
      });
    });
    fields.find('.fba-sku-style').on('select2:select', function() {
      $.ajax({
        type: 'GET',
        url:  Routes.variant_fields_fba_products_path(),
        data: {
          entries: [{
            id: id,
            brand_id: fields.find('.fba-sku-brand').val(),
            imprintable_id: $(this).val()
          }]
        },
        dataType: 'script'
      });
    });
    fields.find('.fba-sku-color').on('select2:select', function() {
      $.ajax({
        type: 'GET',
        url:  Routes.variant_fields_fba_products_path(),
        data: {
          entries: [{
            id: id,
            brand_id: fields.find('.fba-sku-brand').val(),
            imprintable_id: fields.find('.fba-sku-style').val(),
            color_id: $(this).val()
          }]
        },
        dataType: 'script'
      });
    });
  };

  $(document).on('nested:fieldAdded', function(event) { initializeForm(event.field.find('.fba-sku-fields'), true); });
  initializeForm($('.fba-skus'));
});
