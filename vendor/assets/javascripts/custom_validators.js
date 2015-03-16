$(function () {
  window.validators_id = window.validators_id || null;
  window.online_validation = false;
  window.form_valid = true;

  if (typeof window.time_zone_offset == "undefined") {
    window.time_zone_offset = 0;
  }

  window.get_trip_date_time = function () {
    var time = window.current_date + ' ' + window.current_time;
    var dateSome = new Date(time);

    //dateSome.setHours(dateSome.getHours()-(dateSome.getTimezoneOffset()/60));
    //dateSome.setHours(dateSome.getHours()-window.time_zone_offset);
    return dateSome;
  };

  window.recheck_validators = function (callback) {
    var form = $('form');
    if (form.length) {
      try {
        form.resetClientSideValidations();
      } catch (e) {
      }

      if (typeof callback == "function") {
        callback();
      }
      var inputs = form.find('.field_with_errors input');
      for (var i = 0; i < inputs.length; i++) {
        $(inputs[i]).focus();
        $(inputs[i]).blur();
      }
    }
  };

  var __indexOf = [].indexOf || function (item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (i in this && this[i] === item) return i;
    }
    return -1;
  };
  var card_types = [
    {
      name: 'amex',
      pattern: /^3[47]/,
      valid_length: [15]
    },
    {
      name: 'diners_club_carte_blanche',
      pattern: /^30[0-5]/,
      valid_length: [14]
    },
    {
      name: 'diners_club_international',
      pattern: /^36/,
      valid_length: [14]
    },
    {
      name: 'jcb',
      pattern: /^35(2[89]|[3-8][0-9])/,
      valid_length: [16]
    },
    {
      name: 'laser',
      pattern: /^(6304|670[69]|6771)/,
      valid_length: [16, 17, 18, 19]
    },
    {
      name: 'visa_electron',
      pattern: /^(4026|417500|4508|4844|491(3|7))/,
      valid_length: [16]
    },
    {
      name: 'visa',
      pattern: /^4/,
      valid_length: [16]
    },
    {
      name: 'mastercard',
      pattern: /^5[1-5]/,
      valid_length: [16]
    },
    {
      name: 'maestro',
      pattern: /^(5018|5020|5038|6304|6759|676[1-3])/,
      valid_length: [12, 13, 14, 15, 16, 17, 18, 19]
    },
    {
      name: 'discover',
      pattern: /^(6011|622(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9[0-1][0-9]|92[0-5]|64[4-9])|65)/,
      valid_length: [16]
    }
  ];
  var options, _ref, card, card_type, get_card_type, is_valid_length, is_valid_luhn, normalize, validate, validate_number;

  options = {};
  if ((_ref = options.accept) == null) {
    options.accept = (function () {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = card_types.length; _i < _len; _i++) {
        card = card_types[_i];
        _results.push(card.name);
      }
      return _results;
    })();
  }
  get_card_type = function (number) {
    var _j, _len1, _ref2;
    _ref2 = (function () {
      var _k, _len1, _ref2, _results;
      _results = [];
      for (_k = 0, _len1 = card_types.length; _k < _len1; _k++) {
        card = card_types[_k];
        if (_ref2 = card.name, __indexOf.call(options.accept, _ref2) >= 0) {
          _results.push(card);
        }
      }
      return _results;
    })();
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      card_type = _ref2[_j];
      if (number.match(card_type.pattern)) {
        return card_type;
      }
    }
    return null;
  };
  is_valid_luhn = function (number) {
    var digit, n, sum, _j, _len1, _ref2;
    sum = 0;
    _ref2 = number.split('').reverse();
    for (n = _j = 0, _len1 = _ref2.length; _j < _len1; n = ++_j) {
      digit = _ref2[n];
      digit = +digit;
      if (n % 2) {
        digit *= 2;
        if (digit < 10) {
          sum += digit;
        } else {
          sum += digit - 9;
        }
      } else {
        sum += digit;
      }
    }
    return sum % 10 === 0;
  };
  is_valid_length = function (number, card_type) {
    var _ref2;
    return _ref2 = number.length, __indexOf.call(card_type.valid_length, _ref2) >= 0;
  };
  validate_number = function (number) {
    var length_valid, luhn_valid;
    card_type = get_card_type(number);
    luhn_valid = false;
    length_valid = false;
    if (card_type != null) {
      luhn_valid = is_valid_luhn(number);
      length_valid = is_valid_length(number, card_type);
    }
    return {
      card_type: card_type,
      luhn_valid: luhn_valid,
      length_valid: length_valid
    };
  };
  validate = function (element) {
    var number;
    number = normalize($(element).val());
    return validate_number(number);
  };
  normalize = function (number) {
    return number.replace(/[ -]/g, '');
  };

  ClientSideValidations.validators.local["credit_card"] = function (element, options) {
    if ($(element).val() == '') return;

    var res = validate(element);
    if (res.card_type == null) {
      $('.icons-credit_card').removeClass('.disabled');
      return options.message;
    }

    var usercreditcardtype = $('#user_credit_card_type');
    if (usercreditcardtype.length > 0) {
      usercreditcardtype.val(res.card_type.name);
    }

    var cardtypename = $('#card_type_name');
    if (cardtypename.length > 0) {
      cardtypename.val(res.card_type.name);
    }


    $('.icons-credit_card').addClass('disabled');

    switch (res.card_type.name) {
      case 'amex':
        $('.icons-american_express').removeClass('disabled');
        break;
      case 'visa_electron':
      case 'visa':
        $('.icons-visa').removeClass('disabled');
        break;
      case 'mastercard':
      case 'maestro':
      case 'discover':
        $('.icons-master_card').removeClass('disabled');
        break;
    }

  };

  ClientSideValidations.validators.local["credit_card_length"] = function (element, options) {
    if ($(element).val() == '') return;

    var res = validate(element);
    if (!res.length_valid) {
      return options.message;
    }
  };

  ClientSideValidations.validators.local["credit_card_cvv"] = function (element, options) {
    if ($(element).val() == '') return;

    var userCreditCard = $('#user_credit_card');
    if (userCreditCard.length == 0) return;

    var card_number = userCreditCard.val();
    card_number = card_number.replace(/\s/, '');
    if (card_number.length == 0) return;

    var cvv = $(element).val();

    var result = true;
    if (card_number.substr(0, 1) == '3') {
      if (/^\d{4}$/.test(cvv))
        result = false;
    } else {
      if (/^\d{3}$/.test(cvv))
        result = false;
    }

    if (result) {
      return options.message;
    }
  };

  ClientSideValidations.validators.local["date"] = function (element, options) {
    var date = $(element).val().split('/');
    var res = new Date(2000 + parseInt(date[1], 10), parseInt(date[0], 10) - 1, 1, 0, 0, 0);
    var now = new Date();
    if (res < now) {
      return options.message;
    }
  };

  ClientSideValidations.validators.local["min_date"] = function (element, options) {
    //var date = $(element).val().split('/');
    var res = new Date($(element).val());
    //var res = new Date(2000 + parseInt(date[1], 10), parseInt(date[0], 10)-1, 1, 0, 0, 0);
    var now = new Date();
    if (res < now) {
      return options.message;
    }
  };

  ClientSideValidations.validators.remote["promo_code"] = function (element, options) {
    var code = $(element).val();
    if (code == '') return '';
    var result = $.ajax({
      url: '/promo/check/' + code,
      async: false
    });

    if (result.status == 404) {
      $('#promo_amount').hide().html('');
      return options.message;
    }

    if (typeof result.responseJSON != "undefined") {
      var amount = result.responseJSON.value;
      var type = result.responseJSON.type;

      if (type > 0) {
        $('#promo_amount').show().html('You saved: ' + parseFloat(amount).toString() + '% ');
      } else {
        $('#promo_amount').show().html('You saved: ' + parseFloat(amount).toString() + '$ ');
      }
    }
  };

  ClientSideValidations.validators.remote["user_email"] = function (element, options) {
    var code = $(element).val();
    if (code == '') return '';
    if ($.ajax({
      url: '/check/email/' + code,
      // async *must* be false
      async: false
    }).status == 404) {
      return options.message;
    }
  };

  ClientSideValidations.validators.remote["user_phone"] = function (element, options) {
    var code = $(element).val();
    if (code == '') return '';
    if ($.ajax({
      url: '/check/phone/' + code + '/' + $('#user_id').val(),
      async: false
    }).status == 404) {
      return options.message;
    }
  };

  ClientSideValidations.validators.remote["request_status"] = function (element, options) {
    var status = $(element).val();
    if (status == '') return '';

    var $requestid = $('#request_id');
    var id = ($requestid.length && $requestid.val()) || 0;

    var response = $.ajax({
      url: '/check/request_status/' + status + '/' + window.user_id + '/' + $('#' + window.resource_name + '_date').val() + '?id=' + id,
      async: false
    });
    if (response.status == 404) {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    }
  };

  ClientSideValidations.validators.remote["request_status_time"] = function (element, options) {
    var time = $(element).val();
    if (time == '') return '';
    time = window.current_date + ' ' + window.current_time;
    var dateSome = new Date(time);

    dateSome.setHours(dateSome.getHours() - (dateSome.getTimezoneOffset() / 60));
    dateSome.setHours(dateSome.getHours() - window.time_zone_offset);

    var status = $('input[name="' + window.resource_name + '[status]"]:checked').val();
    var response = $.ajax({
      url: '/check/request_status_time/' + dateSome.getTime() + '/' + status,
      async: false
    });
    if (response.status == 404) {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    }
  };

  ClientSideValidations.validators.remote["config"] = function (element, options) {
    var id = $(element).attr('data_id');
    var value = $(element).val();
    var response = $.ajax({
      url: '/admin/config/' + id + '.json',
      method: 'POST',
      data: {id: id, value: value},
      async: false,
      beforeSend: function (xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      }
    });
    if (response.status == 404 || response.responseJSON.status == 'error') {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    } else {
      $(element).val(response.responseJSON.value);
    }
  };

  ClientSideValidations.validators.remote["vehicle_rate"] = function (element, options) {
    /*var id = $(element).attr('data_id');
     var value = $(element).val();
     var response = $.ajax({
     url: '/admin/vehicle/' + id + '.json',
     method: 'POST',
     data: {id: id, value: value},
     async: false,
     beforeSend: function(xhr) {
     xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
     }
     });
     if (response.status == 404 || response.responseJSON.status == 'error') {
     try{
     return response.responseJSON.message;
     } catch(e) {
     return options.message;
     }
     } else {
     $(element).val(response.responseJSON.value);
     }*/
  };

  ClientSideValidations.validators.remote["old_password"] = function (element, options) {
    var id = $(element).attr('data_id');
    var value = $(element).val();
    var response = $.ajax({
      url: '/admin/config/' + id + '.json',
      method: 'POST',
      data: {id: id, old_password: value},
      async: false
    });
    if (response.status == 404 || response.responseJSON.status == 'error') {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    } else {
      $(element).val(response.responseJSON.value);
    }
  };

  ClientSideValidations.validators.remote["driver_available"] = function (element, options) {
    var status = $('input[name="' + window.resource_name + '[status]"]:checked').val();

    var response = $.ajax({
      url: '/check/driver_available/' + status,
      async: false
    });
    if (response.status == 404 || response.responseJSON.status == 'error') {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    }
  };

  ClientSideValidations.validators.remote["promo_code_unique"] = function (element, options) {
    var id = window.validators_id;
    var value = $(element).val();
    var url = '/check/promo_code_unique/' + value;
    if (id != null) {
      url += '/' + id;
    }
    var response = $.ajax({ url: url, async: false });
    if (response.status == 404 || response.responseJSON.status == 'error') {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    }
  };
  ClientSideValidations.validators.remote["promo_name_unique"] = function (element, options) {
    var id = window.validators_id;
    var value = $(element).val();
    var url = '/check/promo_name_unique/' + value;
    if (id != null) {
      url += '/' + id;
    }
    var response = $.ajax({ url: url, async: false });
    if (response.status == 404 || response.responseJSON.status == 'error') {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    }
  };

  ClientSideValidations.validators.local["confirmation"] = function (element, options) {
    var confirm = $(element).val();
    var password = $('#user_password_confirmation').val();
    if (confirm == '' || confirm != password) {
      return options.message;
    }
    return false;
  };

  ClientSideValidations.validators.local["request_places"] = function (element, options) {
    var address = $(element).val();
    if (address == '') {
      return false;
    }
    var from = $('#Request_from').val();
    if (from == address) {
      return options.message;
    }
    return false;
  };

  ClientSideValidations.validators.remote["geofence"] = function (element, options) {
    var lat = window.from.geometry.location.lat();
    var lng = window.from.geometry.location.lng();

    var response = $.ajax({ url: "/check/pu?lat=" + lat + "&lng=" + lng, async: false, method: 'GET' });

    if (response.status == 404 || response.responseJSON.status == 'error') {
      try {
        return response.responseJSON.message;
      } catch (e) {
        return options.message;
      }
    }
    return "";
  };

  ClientSideValidations.validators.remote["credit_card_online"] = function (element, options) {
//    if (window.online_validation)
//      return;

    window.online_validation = false;

    var $userCreditCard = $('#user_credit_card');
    var userCvv = $('#user_cvv');
    var $userExpirationDateMonth = $('#user_expiration_date_month');
    var $userExpirationDateYear = $('#user_expiration_date_year');

    var number = $userCreditCard.val();
    var cvv = userCvv.val();
    var month = $userExpirationDateMonth.val();
    var full_year = $userExpirationDateYear.val();
    var first_name = $('#user_first_name').val();
    var last_name = $('#user_last_name').val();
    var phone = $('#user_phone').val();
    var email = $('#user_email').val();
    var year = full_year.substr(2, 2);
    var zip = "";
    var $userBusinessZipCode = $('#user_business_zip_code');
    if ($userBusinessZipCode.length > 0) {
      zip = $userBusinessZipCode.val();
    } else {
      zip = $('#user_postal_code').val();
    }


    if (month.length < 2)
      month = '0' + month;

    if (number == '' || cvv == '' || zip == '' || month == 0 || year == 0)
      return;

    var forms = $('.formError:visible');
    var cc_errors = [];
    if (forms.length > 0) {
      var flag = false;
      var length = forms.length;
      for (var i = 0; i < length; ++i) {
        if ("custom" == $(forms[i]).attr("data-validate-type"))
          cc_errors[cc_errors.length] = forms[i];
        else
          flag = true;
      }
      if (flag)
        return;
    }

    var url = '/check/card/';
    var data = {
      number: number,
      cvv: cvv,
      date: month.toString() + year.toString(),
      first_name: first_name,
      last_name: last_name,
      phone: phone,
      email: email,
      month: month,
      year: full_year,
      zip: zip
    };

    var loaderGif = $('#loader_gif');

    if (loaderGif.length > 0)
      loaderGif.show();

    var popupCCValidationError = $('#popup_cc_validation_error');
    popupCCValidationError.hide();

    var response = $.ajax({ url: url, async: false, method: 'POST', data: data, cache: false });

    if (loaderGif.length > 0)
      loaderGif.hide();

    var elements = [$userCreditCard, userCvv, $userExpirationDateMonth, $userExpirationDateYear];
    if ($('#user_postal_code').length > 0) {
      elements[elements.length] = $('#user_postal_code');
    }

    if (response.status == 404 || response.responseJSON.status == 'error') {
      window.form_valid = false;
      var message;

      try {
        message = response.responseJSON.message;
      } catch (e) {
        message = options.message;
      }

      for (var indx in elements) {
        if (elements.hasOwnProperty(indx)) {
          var element2 = elements[indx];
          var id = '#popup_' + $(element2).attr('id') + '_error';
          //alert(id);
          window.ClientSideValidations.formBuilders['ActionView::Helpers::FormBuilder'].add(element2, null, message);
          $(id).hide();
          $(id).parent().removeClass('field_with_errors');
        }
      }

      popupCCValidationError.show();

      return false;
    } else {
      window.form_valid = true;
      for (var indx in elements) {
        if (elements.hasOwnProperty(indx))
          window.ClientSideValidations.formBuilders['ActionView::Helpers::FormBuilder'].remove(elements[indx], null);
      }
    }

  };

});