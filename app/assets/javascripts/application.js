// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.

//= require jquery/jquery.js
//= require jquery-ui
//= require jquery_ujs
//= require slimscroll/jquery.slimscroll
//= require select/bootstrap-select
//= require input/bootstrap.file-input
//= require icheck/icheck
//= require wizard/jquery.easyWizard
//= require jquery/jquery.maskedinput.min.js
//= require bigdecimal/bigdecimal-all-last.min.js
//= require select2/select2.full.js
//= require_tree ../../../vendor/assets/javascripts/jquery/.
//= require lanceng/lanceng
//= require table-fixed-header/table-fixed-header
//= require js-routes
//= require moment
//= require bootstrap-datetimepicker/bootstrap-datetimepicker
//= require jquery.remotipart
//= require sortable/sortable
//= require datepicker/bootstrap-datepicker
//= require bootstrap/bootstrap
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require editable/bootstrap-editable
//= require editable/rails
//= require markitup
//= require markitup/sets/xbbcode/set
//= require jquery_nested_form
//= require jquery.minicolors
//= require list
//= require list.fuzzysearch
//= require jquery/jquery.creditCardValidator.js
//= require dropzone

//= require_tree .

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};