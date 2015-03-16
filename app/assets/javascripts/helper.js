/**
 * Created by dima on 19.12.13.
 */
function Helper(){}
Helper.formatted_date = function(date, utc) {
  utc = utc || false;
  if (utc) {
    return str_pad(date.getUTCMonth()+1, 2) + '/' + str_pad(date.getUTCDate(), 2) + '/' + date.getUTCFullYear();
  }
  return str_pad(date.getMonth()+1, 2) + '/' + str_pad(date.getDate(), 2) + '/' + date.getFullYear();
};
Helper.formatted_time = function(date, utc) {
  utc = utc || false;
  var hours;
  if(utc) {
    hours = date.getUTCHours();
    return Helper.format_time(hours, date.getUTCMinutes());
  }

  hours = date.getHours();
  return Helper.format_time(hours, date.getMinutes());
};
/**
 *
 * @param {number} hours
 * @param {number} minutes
 * @return {String}
 */
Helper.format_time = function(hours, minutes) {
  var dd = "AM";
  if (hours >= 12) {
    hours = hours-12;
    dd = "PM";
  }
  if (hours == 0) {
    hours = 12;
  }
  return str_pad(hours, 2) + ':'  + str_pad(minutes, 2) + ' ' + dd;
};

/**
 * @param date
 * @returns {string}
 */
Helper.formatted_datetime = function(date) {
  return Helper.formatted_date(date) + ' - ' + Helper.formatted_time(date);
};
/**
 * @param element
 */
Helper.reformDate = function(element) {
  if ($(element).attr('data-date')) {
    var date = new Date($(element).attr('data-date'));
    $(element).html(Helper.formatted_datetime(date));
    $(element).val(Helper.formatted_datetime(date));
  }
};
/**
 * @param xhr
 */
Helper.before_send = function(xhr) {
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
};
/**
 * @param {String} url
 * @param {Object} [qdata]
 * @param {function} [success_callback]
 * @param {function} [fail_callback]
 */
Helper.simple_ajax = function(url, qdata, success_callback, fail_callback) {
  qdata = qdata || {};
  $.ajax({
    url: url,
    method: 'POST',
    data: qdata,
    beforeSend: Helper.before_send
  }).success(function (data) {
      if (typeof success_callback === "function") { success_callback(data); }
    }).fail(function (data) {
      if (typeof fail_callback === "function") { fail_callback(data); }
    });
};
/**
 * @param url
 * @param [data]
 * @param [method]
 * @returns {*}
 */
Helper.async_ajax = function(url, data, method) {
  method = method || 'POST';
  data = data || {};
  return $.ajax({
    url: url,
    method: method,
    data: data,
    async: false,
    beforeSend: Helper.before_send
  });
};