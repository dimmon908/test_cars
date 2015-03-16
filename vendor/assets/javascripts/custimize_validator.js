jQuery(function() {
  if (typeof window.input_validate_status === "undefined") {
    window.input_validate_status = {};
  }

  var ADDITIONAL_FIELDS = {
    user_password: 'user_password_confirmation'
  };

  var WITH_FIELDS = {
//    user_phone: 'user_phone_code'
  };

  var alerts = $('#summary_errors');
  var add_error = function(message, element) {

    var elem_id = $(element).attr('id');
    if (ADDITIONAL_FIELDS[elem_id]) {
      if ($('#' + ADDITIONAL_FIELDS[elem_id]).is(':focus')) { return; }
      if ($('#' + ADDITIONAL_FIELDS[elem_id]).hasClass('none_focused')) { return; }
      $(element).removeClass('valid');
      element = $('#' + ADDITIONAL_FIELDS[elem_id]);
    }

    var id = $(element).attr('id') + '_error';
    if (alerts.find('li#' + id).length) {
      alerts.find('li#' + id).html(message);
    } else {
      $(element).parent().addClass('field_with_errors');
    }
    $(element).removeClass('valid');

    var popup_id = '#popup_' + id;
    if ($(popup_id).length) {
      $(popup_id).find('.formErrorContent').html(' * ' + message);
      $(popup_id).show();
    }  else {
      var popup = jQuery('#error_popup').html();
      var height = $(element).parent().height();
      popup = popup.replace(/__error_id__/g, 'popup_' + id).replace(/__content__/g, message).replace(/top: \d+px;/g, 'top: ' + (height-10) + 'px;');
      $(element).after(popup);
    }
  };
  var remove_error = function(element) {
    var elem_id = $(element).attr('id');
    if (ADDITIONAL_FIELDS[elem_id]) {
      if ($('#' + ADDITIONAL_FIELDS[elem_id]).is(':focus')) { return; }
      $(element).addClass('valid');
      element = $('#' + ADDITIONAL_FIELDS[elem_id]);
    }

    var id = $(element).attr('id') + '_error';

    $(element).parent().removeClass('field_with_errors');
    $(element).addClass('valid');

    var popup_id = '#popup_' + id;
    $(popup_id).remove();
  };
  window.ClientSideValidations.formBuilders['ActionView::Helpers::FormBuilder'] = {
    add: function(element, settings, message) {
      add_error(message, element);
    },
    remove: function(element, settings) {
      remove_error(element)
    }
  };


  window.ClientSideValidations.callbacks.element.before = function(element, eventData) {
    var id = $(element).attr('id');
    if (id != '') {

      if (typeof window.input_validate_status[id] === "undefined") { window.input_validate_status[id] = {}; }

      var error_id  = '#popup_' + id + '_error';
      if ($(error_id).length > 0 && window.input_validate_status[id]['changed']) {
        $(error_id).show();
        $(element).parent().addClass('field_with_errors');
      }
    }


    var with_field = $('#' + WITH_FIELDS[id]);
    if (typeof WITH_FIELDS[id] !== "undefined" && $(element).val() != '' && with_field.length) {
      $(element).attr('old-value', $(element).val());
      var matches =  with_field.val().match(/\d+/);
      if (matches != null) {
        $(element).val(matches.join('') + $(element).val());
      }

    }

  };

  window.ClientSideValidations.callbacks.element.after = function(element, eventData) {
    var id = $(element).attr('id');
    if (typeof WITH_FIELDS[id] !== "undefined" && $(element).attr('old-value')) {
      $(element).val($(element).attr('old-value'));
    }
  };
});