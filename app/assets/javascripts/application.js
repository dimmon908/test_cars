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
//= require bootstrap/bootstrap.min.js
//= require rails.validations
//= require extend_datetimepicker
//= require jquery.remotipart
//= require other/jquery.isloading.min.js
//= require bootstrap-datepicker
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

function get_message(message, need_i) {
  if (typeof message !== "object") { return message; }
  if (typeof need_i === "undefined") { need_i = true; }

  var response = '';
  for(var i in message) {
    if (!message.hasOwnProperty(i)) { continue; }
    if (message[i] == '' || message[i] == null) { continue; }
    if (need_i) {
      response += ' - ' + i + ':  ' + message[i] +  '<br/>';
    } else {
      response += ' - ' + message[i] + '<br/>';
    }

  }
  return response;
}

(function($) {
  $(function() {
    $("[data-toggle='tooltip']").tooltip();
    $('.datetime[data-date]').each(function(index, value) { Helper.reformDate(value); });
  });
})(jQuery);

