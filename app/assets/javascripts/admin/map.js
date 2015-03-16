/**
 * @type {Array<google.maps.Marker>}
 */
var markersArray = [];
var driver_info_windows = [];
var driver_info_windows_opened = [];
var minZoomLevel = 10;
var maxZoomLevel = 20;

jQuery(function () {
  var last_data = {};

  window.setTab = function(element) {
    var parent = $(element).parents().find('.request_details');
    var href = $(element).attr('href');
    $(parent).find('.tab-pane').removeClass('active');
    $(parent).find('.tabs li').removeClass('active');
    $(element).parent().addClass('active');
    $(href).addClass('active');
  };

  window.send_driver_message = function(id) {
    var element = $('#driver_message_' + id);
    if (element.length == 0 || element.val() == '') return false;
    var success = $('#send_message_ok_' + id);
    var errors = $('#send_message_errors_' + id);
    var success_func = function(data) {
        if (data && data.status == 'ok') {
          success.show();
          errors.hide();
        } else if(data && data.message) {
          success.hide();
        errors.show().html(data.message);
        } else {
          success.hide();
        errors.show().html('some error');
        }
    };
    var fail_func = function() {
        success.hide();
      errors.show().html('some error');
  };

    Helper.simple_ajax('driver/message', {id: id, message: element.val()}, success_func, fail_func);

    return false;
  };

  var addDriverGoto = function(driver) {
    var row = $('#driver_goto_template').html();
    row = row.
      replace(/__lat__/ig, driver.coordinates.lat).
      replace(/__lng__/ig, driver.coordinates.lng).
      replace(/__id__/ig, driver.coordinates.id).
      replace(/__driver_name__/ig, driver.name);
    $('#drivers_markers_goto').append(row);
  };

  /**
   * @param {{status: string, data: {summary: {available: string, booked: string, unavailable: string, total: string}, drivers: {}}}} data
   * @returns {boolean}
   */
  var paintMapInfo = function (data) {
    if (typeof data == "undefined") return false;
    if (typeof data.status == "undefined") return false;
    if (data.status == "error") return data.message;
    if (data.status != "ok") return false;

    if (data.data.summary) {
      $('#driver_available').html(data.data.summary.available);
      $('#driver_booked').html(data.data.summary.booked);
      $('#driver_unavailable').html(data.data.summary.unavailable);
      $('#driver_total').html(data.data.summary.total);
    }

    clearOverlays();
    if (data.data.drivers) {
      $('#drivers_markers_goto').html('');
      var drivers = data.data.drivers, driver, position;
      var i;
      if (drivers.available != null && $('#drivers_available').prop('checked')) {
        i = drivers.available.length - 1;
        while (i >= 0) {
          driver = drivers.available[i];
          position = new google.maps.LatLng(driver.coordinates.lat, driver.coordinates.lng);
          placeMarker(position, driver.name, '/img/driver/available.png', driver.id);
          placeWindow(driver.id, driver, driver.request);
          --i;

          addDriverGoto(driver);
        }
      }

      if (drivers.booked != null && $('#drivers_booked').prop('checked')) {
        i = drivers.booked.length - 1;
        while (i >= 0) {
          driver = drivers.booked[i];
          position = new google.maps.LatLng(driver.coordinates.lat, driver.coordinates.lng);
          placeMarker(position, driver.name, '/img/driver/booked.png', driver.id);
          placeWindow(driver.id, driver, driver.request);
          --i;

          addDriverGoto(driver);
        }
      }

      if (drivers.unavailable != null && $('#drivers_unavailable').prop('checked')) {
        i = drivers.unavailable.length - 1;
        while (i >= 0) {
          driver = drivers.unavailable[i];
          position = new google.maps.LatLng(driver.coordinates.lat, driver.coordinates.lng);
          placeMarker(position, driver.name, '/img/driver/unavailable.png', driver.id);
          placeWindow(driver.id, driver, driver.request);
          --i;

          addDriverGoto(driver);
        }
      }
    }
    return true;
  };
  /**
   * @param driver
   * @param request
   * @returns {*|jQuery}
   */
  var getInfoWindowHtml = function(driver, request) {
    var html = $('#driver_popup').html();
    html = html.
      replace(/__DRIVER_NAME__/ig, driver.name).
      replace(/__CAR_TYPE__/ig, driver.car_type).
      replace(/__IMG__/ig, '<img src="' + driver.car.url  +'" id="img_' + driver.id + '" style="margin: 20px;width:auto;"/>').
      replace(/__NAME__/ig, driver.car.name).
      replace(/__DESC__/ig, driver.car.desc).
      replace(/__id__/ig, driver.id);

    if (request != null) {
      html = html.
        replace(/__NOTES__/ig, request.notes).
        replace(/__ETA__/ig, request.eta).
        replace(/__DATE__/ig, request.date).
        replace(/__RATE__/ig, request.rate).
        replace(/__visible__/ig, 'block');
    } else {
      html = html.replace(/__visible__/ig, 'none');
    }

    if (driver.break != null) {
      html = html.
        replace(/__break_visible__/ig, 'block').
        replace(/__BREAK_COUNT__/ig, driver.break.count).
        replace(/__REMAIN_BREAK__/ig, driver.break.left);
    } else {
      html = html.replace(/__break_visible__/ig, 'none');
    }


    return html;
  };
  /**
   * @param id
   * @param driver
   * @param request
   */
  var setInfoWindowBlock = function(id, driver, request) {
    if (request != null) {

      $('#trip_info_' + id).css('display', '');
      $('#notes_block_' + id).css('display', '');
      $('#rate_block_' + id).css('display', '');

      $('#request_time_' + id).css('display', '');

      $('#notes_' + id).html(request.notes);
      $('#date_' + id).html(request.date);
      $('#eta_' + id).html(request.eta);
      $('#rate_' + id).html(request.rate);
    } else {
      $('#trip_info_' + id).hide();
      $('#notes_block_' + id).hide();
      $('#request_time_' + id).hide();
      $('#rate_block_' + id).hide();
    }

    if (driver.break) {
      $('#break_block_' + id).css('display', '');
      $('#break_count_' + id).html(driver.break.count);
      $('#break_left_' + id).html(driver.break.left);
    }

    $('#driver_name_' + id).html(driver.name);
    $('#car_type_' + id).html(driver.car_type);
    $('#img_' + id).attr('src', driver.car.url);
    $('#car_name_' + id).html(driver.car.name);
    $('#car_desc_' + id).html(driver.car.desc);


  };

  /**
   * @param id
   * @param driver
   * @param request
   */
  var placeWindow = function(id, driver, request) {

    var html = getInfoWindowHtml(driver, request);
    if (driver_info_windows.hasOwnProperty(id)) {
      setInfoWindowBlock(id, driver, request);
    } else {
      var myOptions = {
        content: html
        ,disableAutoPan: false
        ,maxWidth: 0
        ,pixelOffset: new google.maps.Size(40, -90)
        ,zIndex: null
        ,closeBoxMargin: "10px 2px 2px 2px"
        ,closeBoxURL: "http://www.google.com/intl/en_us/mapfiles/close.gif"
        ,infoBoxClearance: new google.maps.Size(1, 1)
        ,isHidden: false
        ,pane: "floatPane"
        ,enableEventPropagation: false
      };
      driver_info_windows[id] = new InfoBox(myOptions);
      driver_info_windows_opened[id] = false;
    }

    google.maps.event.addListener(markersArray[id], 'click', function() {
      if(driver_info_windows_opened[id]) {
        driver_info_windows[id].close();
        driver_info_windows_opened[id] = false;
      } else {
        driver_info_windows[id].open(Gmaps.map.serviceObject, markersArray[id]);
        driver_info_windows_opened[id] = true;
      }
    });
  };
  /**
   * @param latLng
   * @param text
   * @param icon
   * @param id
   */
  var placeMarker = function (latLng, text, icon, id) {
    var marker = new google.maps.Marker({
      position: latLng,
      map: Gmaps.map.serviceObject,
      draggable: false,
      title: text,
      icon: icon
    });
    if (markersArray.hasOwnProperty(id)) {
      markersArray[id].setMap(null);
    }
    markersArray[id] = marker;
  };

  var clearOverlays = function () {
    var i;
    for(i in markersArray) {
      if (!markersArray.hasOwnProperty(i)) { continue; }
      markersArray[i].setMap(null);
    }
    for (i = 0; i < Gmaps.map.markers.length; i++) {
      Gmaps.map.clearMarker(Gmaps.map.markers[i]);
    }
  };

  // Map handlers
  (function() {
    Gmaps.map.callback = function () {
      google.maps.event.addListener(Gmaps.map.serviceObject, 'zoom_changed', function() {
        if (Gmaps.map.serviceObject.getZoom() < minZoomLevel) {
          Gmaps.map.serviceObject.setZoom(minZoomLevel);
        }
      });
    };

    var func = function (data) {
      last_data = data;
      paintMapInfo(data);
    };
    setInterval(function () {
      if ($('#google_drivers_map').length < 1) { return false; }
      Helper.simple_ajax('/admin/driver/map', {}, func, func);
      return false;
    }, 5000);
  })();

  // Driver Messaging
  (function() {
    $(document).on('click', '#send_broadcast_message', function() {
      var text = $('#broadcast_message').val();
      if (text != '') {
        Helper.simple_ajax('/admin/driver/broadcast', {message: text}, function(data) {
          if (data && data.status == 'ok') {
            $('#broadcast_message_errors').hide();
            $('#broadcast_message_ok').show();
            $('#broadcast_message').val('')
          } else if(data.status == 'error') {
            $('#broadcast_message_errors').show().html(data.message);
            $('#broadcast_message_ok').hide();
          } else {
            $('#broadcast_message_errors').show().html('Some error');
            $('#broadcast_message_ok').hide();
          }
        })
      }
    });
  })();

  // Drivers cheats
  (function(){
    $(document).on('change', '.driver_type', function () {
      paintMapInfo(last_data);
    });
    $(document).on('click', '.goto_driver_marker', function() {
      var position = new google.maps.LatLng(parseFloat($(this).attr('data-lat')), parseFloat($(this).attr('data-lng')));
      Gmaps.map.serviceObject.setCenter(position);
    });
    $(document).on('click', '#driver_total', function() {
      var parent_window = $('#drivers_markers_goto').parent();
      if (parent_window.is(':visible')) {
        parent_window.hide();
      } else {
        parent_window.show();
      }
    });
  })();
});
