// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery-migrate-1.2.1.min.js
//= require jquery.remotipart
//= require system/html5shiv.js
//= require system/less.min.js
//= require system/jquery.event.move/jquery.event.move.js
//= require system/jquery.event.swipe/jquery.event.swipe.js
//= require system/jquery-ui/jquery-ui-1.9.2.custom.min.js
//= require system/jquery-ui-touch-punch/jquery.ui.touch-punch.min
//= require system/modernizr.js
//= require system/jquery.cookie.js
//= require bootstrap/bootstrap.min.js
//= require other/jquery-slimScroll/jquery.slimscroll.js
//= require admin/admin
//= require rails.validations
//= require custom_validators
//= require custimize_validator
//= require extend_datetimepicker
//= require helper

/**
 * @param input
 * @param pad_length
 * @param [pad_string]
 * @param [pad_type]
 * @returns {*}
 */
function str_pad( input, pad_length, pad_string, pad_type ) {
  "use strict";
  if (typeof input === "undefined") {
    input = '';
  } else if (typeof input !== "string") {
    input = input.toString();
  }
  if (typeof pad_string === "undefined") { pad_string = '0'; }
  if (typeof pad_type === "undefined") { pad_type = 'STR_PAD_LEFT'; }

  var half = '', pad_to_go;

  var str_pad_repeater = function(s, len){
    var collect = '';

    while(collect.length < len) { collect += s; }
    collect = collect.substr(0,len);

    return collect;
  };

  if (pad_type !== 'STR_PAD_LEFT' && pad_type !== 'STR_PAD_RIGHT' && pad_type !== 'STR_PAD_BOTH') { pad_type = 'STR_PAD_RIGHT'; }
  if ((pad_to_go = pad_length - input.length) > 0) {
    if (pad_type === 'STR_PAD_LEFT') { input = str_pad_repeater(pad_string, pad_to_go) + input; }
    else if (pad_type === 'STR_PAD_RIGHT') { input = input + str_pad_repeater(pad_string, pad_to_go); }
    else if (pad_type === 'STR_PAD_BOTH') {
      half = str_pad_repeater(pad_string, Math.ceil(pad_to_go/2));
      input = half + input + half;
      input = input.substr(0, pad_length);
    }
  }

  return input;
}

(function($) {
  $(function() {
    $('[data-date]').each(function(index, value) { Helper.reformDate(value); });
  });
})(jQuery);