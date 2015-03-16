/**
 * Created with JetBrains RubyMine.
 * User: dima
 * Date: 21.10.13
 * Time: 19:03
 * To change this template use File | Settings | File Templates.
 */
window.current_anchor = '';
window.current_date = '';
window.current_time = '';
window.current_to_points = 0;
window.current_to = [];
window.cur_trip_id = null;
window.can_click = true;

window.driver_info_window = null;
window.driver_info_window_opened = false;
/** @type {google.maps.Marker} */
window.driver_marker = null;

window.refresh_tab_timeout = null;
window.timeout_id = null;
window.autocompletes = {};
if (typeof window.referrers_email === "undefined") {
    window.referrers_email = 0;
}
if (typeof window.current_begin_date === "undefined") {
    /** @type {Date} */
    window.current_begin_date = new Date();
}
if (typeof window.only_future_vehicle === "undefined") {
    window.only_future_vehicle = [];
}
window.errors_on_bottom = ['recommended_first_name', 'recommended_last_name', 'recommended_phone'];
window.errors_on_submit = ['no_driver'];

/**
 * @param element
 */
window.setTab = function (element) {
    var parent = $(element).parents().find('.request_details');
    var href = $(element).attr('href');
    $(parent).find('.tab-pane').removeClass('active');
    $(parent).find('.tabs li').removeClass('active');
    $(element).parent().addClass('active');
    $(href).addClass('active');
};

/**
 * @param element
 * @param [street]
 * @param [city]
 * @param [latLng]
 * @param [need_geo]
 * @param [name]
 */
window.change_address = function (element, street, city, latLng, need_geo, name) {
    var flag = false;
    var address = $(element).val();

    name = name || '';

    if (typeof need_geo === "undefined") {
        need_geo = true;
    }

    if (window.check_favorite(address)) {
        $(element).parent().
            removeClass('exist').
            find('.favorite_star').removeClass('exist');
    } else {
        $(element).
            parent().addClass('exist').
            find('.favorite_star').addClass('exist');
    }

    if (typeof street !== "undefined") {
        $(element).attr('data-street', street);
    } else {
        flag = true;
    }

    if (typeof city !== "undefined") {
        $(element).attr('data-city', city);
    } else {
        flag = true;
    }

    if (typeof latLng !== "undefined") {
        $(element).
            attr('data-lat', latLng.lat()).
            attr('data-lng', latLng.lng());
    } else {
        flag = true;
    }

    $(element).attr('data-name', name);

    if (flag && need_geo) {
        var geocoder = new google.maps.Geocoder();
        if (geocoder) {
            geocoder.geocode({'address': address}, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    results[0].address_components = results[0].address_components || [];

                    var value = results[0].formatted_address || '';
                    var location = results[0].geometry.location;
                    var gAddress = new GoogleAddress(results[0].address_components, results[0].name);

                    $(element).
                        attr('data-city', gAddress.city()).
                        attr('data-street', gAddress.street()).
                        attr('data-name', gAddress.name()).
                        attr('data-lat', location.lat()).
                        attr('data-lng', location.lng()).
                        val(value);
                }
            });
        }
    }
};

window.add_way_point = function () {
    var tmpl = $('#dest_temp').html();
    window.current_to_points++;
    tmpl = tmpl.replace(/__i__/ig, window.current_to_points);
    var i = window.current_to_points;

    $('#beforeVechicle').before(tmpl);

    window.input_autocomplete('Request_to_' + window.current_to_points, defaults.DESTINATION_ICON, function (result) {
        window.current_to[i] = result;
        window.direction();
    });

    return ('Request_to_' + window.current_to_points.toString());
};

/**
 * @param element
 * @param city
 * @param street
 * @param [lat]
 * @param [lng]
 * @param [name]
 */
window.add_favorite = function (element, city, street, lat, lng, name) {
    if ($(element).parents('.favorites').hasClass('exist')) {
        return;
    }

    lat = lat || false;
    lng = lng || false;

    $.ajax({
        url: '/favorites/add',
        method: 'POST',
        data: {address: $(element).attr('data-address'), city: city, street: street, lat: lat, lng: lng, name: name},
        dataType: 'json'
    }).success(function (data) {
        if (data && data.status == 'ok') {
            $(element).parents('.favorites').addClass('exist');
            $(element).addClass('exist');
            window.refresh_favorites();
        }
    });
};
/**
 * @param id
 */
window.remove_favorite = function (id) {
    $.ajax({
        url: '/favorites/remove',
        method: 'POST',
        data: {id: id},
        dataType: 'json'
    }).success(function (data) {
        if (data && data.status == 'ok') {
            $('.address_book_item[data-id="' + id + '"]').animate({
                top: '-33%',
                marginTop: -275
            }, 400, 'swing', function () {
                $(this).remove();
            });
        }
    });
};

window.refresh_favorites = function () {
    var selected = $('.address_book_item.active');
    var id = '';
    if (selected.length) {
        id = selected.attr('data-id')
    }
    $.ajax({
        url: '/favorites/list',
        method: 'POST',
        data: {selected: id}
    }).success(function (data) {
        if (data != '') {
            $('#favorites_list').html(data);
        }
    });
};

window.check_favorite = function (address) {
    var selected = $('.address_book_item.active');
    var id = '';
    if (selected.length) {
        id = selected.attr('data-id')
    }
    var response = $.ajax({
        url: '/favorites/exist',
        method: 'POST',
        data: {address: address},
        async: false
    });

    return typeof response.responseJSON !== "undefined" && response.responseJSON.status == 'ok';
};

jQuery(function () {

    window.current_to = [
        {
            geometry: {location: (new google.maps.LatLng(0, 0))},
            formatted_address: ''
        }
    ];

    var init_datepickers = function (callback, startDate) {
        $('.datepicker').datetimepicker({
            pickTime: false,
            startDate: startDate
        }).on('changeDate',function (e) {
            var input = $(this).parent().find('input');
            var date_str, time_str, choosed = e.date;
            if (input.val() == '') {
                time_str = Helper.formatted_time(choosed, true);
            } else {
                time_str = $.trim(input.val()).split(' - ')[1];
            }

            date_str = Helper.formatted_date(choosed, true);
            window.recheck_validators(function () {
                input.val(date_str + ' - ' + time_str);
            });

            if (typeof callback === "function") {
                callback();
            }
            window.current_date = date_str;
            if (window.current_time == '') {
                window.current_time = str_pad(window.current_begin_date.getUTCHours(), 2) + ':' + str_pad(window.current_begin_date.getUTCMinutes(), 2);
            }

            if (isFutureRequest()) {
                showFutureVehicle();
            }
        }).each(setPickerDate);

        $('.timepicker').datetimepicker({
            pickDate: false,
            pick12HourFormat: true,
            pickSeconds: false
        }).on('changeDate',function (e) {
            var input = $(this).parent().find('input');
            var date_str, choosed = e.date, time_str;
            if (input.val() == '') {
                date_str = Helper.formatted_date(choosed, true);
            } else {
                date_str = $.trim(input.val()).split(' - ')[0];
            }
            time_str = Helper.formatted_time(choosed, true);
            window.recheck_validators(function () {
                input.val(date_str + ' - ' + time_str);
            });

            if (window.current_date == '') {
                window.current_date = date_str;
            }
            window.current_time = str_pad(choosed.getUTCHours(), 2) + ':' + str_pad(choosed.getUTCMinutes(), 2);

            if (isFutureRequest()) {
                showFutureVehicle();
            }
        }).each(setPickerDate);
    };

    /**
     * @param selector
     * @param selector2
     * @param link
     * @param [anchor]
     * @param [date_picker_callback]
     * @param [date]
     * @param [callback]
     */
    var init_tab = function (selector, selector2, link, anchor, date_picker_callback, date, callback) {
        if (typeof anchor === "undefined") {
            anchor = '';
        }

        jQuery(document).on('click', selector2, function () {
            if ($(selector).hasClass('active') && !$(selector).hasClass('ignore-active')) {
                return false;
            }

            jQuery.ajax({
                url: link
            }).success(function (data) {
                if (data) {
                    if (window.refresh_tab_timeout != null) {
                        clearTimeout(window.refresh_tab_timeout);
                        window.refresh_tab_timeout = null;
                    }
                    clearDirections();
                    window.clearOverlays();
                    if (window.timeout_id != null) {
                        clearTimeout(window.timeout_id);
                        window.timeout_id = null;
                        window.cur_trip_id = 0;
                    }

                    content.html(data);
                    jQuery('#address_book_block').hide();
                    $('.nav.nav-tabs.request-tabs .active').removeClass('active');
                    $(selector).addClass('active');

                    init_datepickers(date_picker_callback, date);
                    trasnformDate();

                    if (anchor != '') {
                        document.location.href = document.location.href.split('#')[0] + '#' + anchor;
                        window.current_anchor = anchor;
                    }

                    if (typeof callback === "function") {
                        callback();
                    }
                }
            });

            return false;
        });
    };

    var anchor = function () {
        var stripped_url = document.location.toString().split("#");
        if (stripped_url.length > 1) {
            return stripped_url[1];
        }
        return '';
    };

    var init_anchor = function (anchor_value) {
        if (typeof anchor_value == "undefined") {
            anchor_value = anchor()
        }
        if (anchor_value == window.current_anchor) {
            return '';
        }

        window.current_anchor = anchor_value;

        switch (anchor_value) {
            case 'active_list':
                $('#active_list').click();
                break;
            case 'new_request':
                $('#new_request_tab').click();
                break;
            case 'past_list':
                $('#past_list').click();
                break;
            default:
                break;
        }

        return false;
    };

    var content = jQuery('#new_request');

    jQuery(document).on('click', '#add_passenger', function () {
        var passengers = jQuery('#passengers');
        var count = passengers.children().length;
        if (jQuery('#passengers_count').val() <= count) {
            return;
        }
        var template = jQuery('#passenger_tmp').html();
        template = template.replace(/__number__/g, count + 1).replace(/__id__/g, count);
        passengers.append(template);
    });

    $(document).on("keypress", 'form', function (e) {
        var code = e.keyCode || e.which;
        if (code == 13) {
            e.preventDefault();
            return false;
        }
        return e;
    });

    jQuery(document).on('click', '.notify_phone_trigger', function () {
        var id = jQuery(this).attr('id').replace('notify_phone_trigger_', '');

        jQuery(this).addClass('active');
        jQuery('#notify_email_trigger_' + id).removeClass('active');
        jQuery('#notify_phone_' + id).show();
        jQuery('#notify_email_' + id).hide();
        jQuery('#notify_trigger_type_' + id).val('phone');
    });
    jQuery(document).on('click', '.notify_email_trigger', function () {
        var id = jQuery(this).attr('id').replace('notify_email_trigger_', '');
        jQuery(this).addClass('active');
        jQuery('#notify_phone_trigger_' + id).removeClass('active');
        jQuery('#notify_email_' + id).show();
        jQuery('#notify_phone_' + id).hide();
        jQuery('#notify_trigger_type_' + id).val('email');
    });

    jQuery(document).on('click', '#add_notification', function () {
        var max = jQuery('#max_notify_count').val();
        var notifications = jQuery('#notifications');
        var count = notifications.children().length;
        if (count < max) {
            var html = jQuery('#notify_tmp').html();
            html = html.replace(/__i__/g, count);
            notifications.append(html);
        }
    });

    function mergeWithRecommend(messages) {
        var reccomend = [];
        for (var i in window.errors_on_bottom) {
            if (!window.errors_on_bottom.hasOwnProperty(i)) {
                continue;
            }

            var field = window.errors_on_bottom[i];

            if (messages.hasOwnProperty(field)) {
                reccomend[field] = messages[field];
                messages[field] = null;
            }
        }
        return get_message(reccomend, false);
    }

    function mergeWithSubmit(messages) {
        var submit = [];
        for (var i in window.errors_on_submit) {
            if (!window.errors_on_submit.hasOwnProperty(i)) {
                continue;
            }

            var field = window.errors_on_submit[i];

            if (messages.hasOwnProperty(field)) {
                submit[field] = messages[field];
                messages[field] = null;
            }
        }
        return get_message(submit, false);
    }

    function displayErrors(json) {
        var errorsBlock = $('#errors_block');
        errorsBlock.show();
        if (json && json.messages) {
            var messages;
            if (typeof json.messages == "string") {
                messages = JSON.parse(json.messages);
            } else {
                messages = json.messages;
            }

            var recommend_messages = mergeWithRecommend(messages);
            var submit_messages = mergeWithSubmit(messages);
            errorsBlock.find('p').html(get_message(messages, false));

            if (recommend_messages != '') {
                $('#errors_passenger_block').show().html(recommend_messages);
            } else {
                $('#errors_passenger_block').hide();
            }

            if (submit_messages != '') {
                $('#errors_submit_block').show().html(submit_messages);
            } else {
                $('#errors_submit_block').hide();
            }

        } else {
            errorsBlock.find('p').html('Some error');
            $('#errors_passenger_block').hide();
            $('#errors_submit_block').hide();
        }
    }

    function addInfoToPost(valuesToSubmit) {
        $('.address_select').each(function (index, data) {
            var id = $(data).attr('id');
            id = id.
                replace('from', 'from_coordinates').
                replace('Request_', '').
                replace('to', 'to_coordinates');

            valuesToSubmit +=
                '&Request[params][' + id + '][lat]=' + $(data).attr('data-lat') +
                    '&Request[params][' + id + '][lng]=' + $(data).attr('data-lng') +
                    '&Request[params][' + id + '][city]=' + $(data).attr('data-city') +
                    '&Request[params][' + id + '][name]=' + $(data).attr('data-name') +
                    '&Request[params][' + id + '][street]=' + $(data).attr('data-street');
        });

        if (window.current_date != '' && window.current_time != '') {

            var dateSome = window.get_trip_date_time();
            var number = 'Request[date]=' + (dateSome.getTime() / 1000);
            valuesToSubmit = number + '&' + valuesToSubmit + '&' + number;
        }

        return valuesToSubmit;
    }

    function editRequestParamsCallback(data) {
        content.html(data);
        jQuery('#address_book_block').hide();
        window.can_click = false;
        if (infowindow != null) {
            infowindow.close();
            infowindow = null;
        }
        if (curretMarkerIndex != null && markersArray.hasOwnProperty(curretMarkerIndex) && markersArray[curretMarkerIndex] != null) {
            markersArray[curretMarkerIndex].setMap(null);
            markersArray[curretMarkerIndex] = null;
        }
    }

    jQuery(document).on('submit', '#new_Request', function () {

        var valuesToSubmit = $(this).serialize();

        valuesToSubmit = addInfoToPost(valuesToSubmit);

        jQuery.ajax({
            url: $(this).attr('action'),
            data: valuesToSubmit,
            method: 'POST',
            dataType: "JSON"
        }).success(function (json) {
            var url = "";
            if (json.hasOwnProperty('id') && json.id != null)
                url = json.id;

            if (json && json.status == 'ok') {
                jQuery.ajax({
                    url: '/request/confirm/' + url,
                    success: editRequestParamsCallback
                })
            } else {
                displayErrors(json);
            }
        });
        return false;
    });

    jQuery(document).on('submit', '#edit_Request', function () {
        var to = jQuery('#route_to').val();
        var valuesToSubmit = $(this).serialize();
        valuesToSubmit = addInfoToPost(valuesToSubmit);

        jQuery.ajax({
            url: $(this).attr('action'),
            data: valuesToSubmit,
            method: 'POST',
            dataType: "JSON"
        }).success(function (json) {
            if (json && json.status == 'ok') {
                jQuery.ajax({
                    url: to,
                    success: editRequestParamsCallback
                })
            } else {
                displayErrors(json);
            }
        });
        return false;
    });

    jQuery(document).on('click', '.edit_trip', function () {

        jQuery.ajax({
            url: '/request/edit/book/',
            success: function (data) {
                content.html(data);
                jQuery('#address_book_block').hide();

                window.input_autocomplete('Request_from', defaults.PICKUP_ICON, function (result) {
                    window.from = result;
                    direction();
                });

                for (var i = window.current_to.length - 1; i > -1; i--) {
                    window.input_autocomplete('Request_to_' + i, defaults.DESTINATION_ICON, function (result, input_data) {

                        if (input_data.i == 0) {
                            window.to = result;
                        }
                        window.current_to[input_data.i] = result;
                        direction();
                    }, {i: i});
                }

                init_datepickers(false, window.current_begin_date);
                trasnformDate();
                initialDateTime();
                window.can_click = true;
            }
        });
        return false;
    });

    function refreshActiveList() {
        var id = $('.request_item.active[data-id]').attr('data-id');
        var link = '/request/active_list/';
        if (id != undefined && id != "undefined")
            link += id;

        jQuery.ajax({
            url: link
        }).success(function (data) {
            if (data) {

                if (window.refresh_tab_timeout != null) {
                    clearTimeout(window.refresh_tab_timeout);
                    window.refresh_tab_timeout = null;
                }
                content.html(data);

                jQuery('.tooltip').each(function (index, data) {
                    $(data).popover({
                        content: $(data).attr('data-content'),
                        placement: 'right',
                        html: true,
                        trigger: 'hover'
                    });
                });

                trasnformDate();

                window.refresh_tab_timeout = setTimeout(function () {
                    refreshActiveList()
                }, 5000);
            }
        });
    }

  (function(){
    var D= new Date('2011-06-02T09:34:29+02:00');
    if(!D || +D!== 1307000069000){
      Date.fromISO= function(s){
        var day, tz,
          rx=/^(\d{4}\-\d\d\-\d\d([tT ][\d:\.]*)?)([zZ]|([+\-])(\d\d):(\d\d))?$/,
          p= rx.exec(s) || [];
        if(p[1]){
          day= p[1].split(/\D/);
          for(var i= 0, L= day.length; i<L; i++){
            day[i]= parseInt(day[i], 10) || 0;
          };
          day[1]-= 1;
          day= new Date(Date.UTC.apply(Date, day));
          if(!day.getDate()) return NaN;
          if(p[5]){
            tz= (parseInt(p[5], 10)*60);
            if(p[6]) tz+= parseInt(p[6], 10);
            if(p[4]== '+') tz*= -1;
            if(tz) day.setUTCMinutes(day.getUTCMinutes()+ tz);
          }
          return day;
        }
        return NaN;
      }
    } else{
      Date.fromISO= function(s){
        return new Date(s);
      }
    }
  })();

    function trasnformDate() {
        $('input[data-date]').each(function (index, value) {
            var date = Date.fromISO($(value).attr('data-date'));

            $(value).val(Helper.formatted_datetime(date));
        });

        $('.date_transform[data-date]').each(function (index, value) {
            var date = Date.fromISO($(value).attr('data-date'));
            $(value).html(Helper.formatted_datetime(date));
        });
    }

    function initialDateTime() {
        var elements = $('.datepicker[data-date]');
        if (elements.length) {
            var element = elements[0];
            var date = Date.fromISO($(element).attr('data-date'));
            date.setHours(date.getHours() - date.getTimezoneOffset() / 60);
            window.current_date = Helper.formatted_date(date, true);
            window.current_time = str_pad(date.getUTCHours(), 2) + ':' + str_pad(date.getUTCMinutes(), 2);
        }
    }

    function setPickerDate(index, value) {
        /*
         var picker = $(value).data('datetimepicker');
         if (!$(value).attr('data-date')) { return; }
         var dateSome = new Date($(value).attr('data-date'));
         dateSome.setHours(dateSome.getHours() - dateSome.getTimezoneOffset()/60);
         picker.setDate(dateSome);
         */
    }

    init_tab(
        '#active_list',
        '#goto_active_list, #active_list, a[href="#active_list_con"]',
        '/request/active_list',
        'active_list',
        false,
        window.current_begin_date,
        function () {
            var items = $('.request_item');
            if (items.length) {
                $(items[0]).click();
                load_trip_info(items[0]);
            }
            if (infowindow != null) {
                infowindow.close();
            }
            refreshActiveList();
            window.can_click = false;
        });
    init_tab('#new_request_tab', '#new_request_tab', '/request/new', 'new_request', false, window.current_begin_date, function () {
        window.input_autocomplete('Request_from', defaults.PICKUP_ICON, function (result) {
            window.from = result;
            direction();
        });
        window.input_autocomplete('Request_to_0', defaults.DESTINATION_ICON, function (result) {
            window.to = result;
            window.current_to[0] = result;
            direction();
        });
        window.autocompletes = {};

        $('#Request_date').attr('placeholder', Helper.formatted_datetime(date));
        window.can_click = true;

        if ($('#Request_from').val() == '') {
            window.from = undefined;
        }

        if ($('#Request_to_0').val() == '') {
            window.to = undefined;
            window.current_to = [];
        }

        direction();
    });
    init_tab('#past_list', '#past_list', '/request/past_list', 'past_list', function () {
        jQuery.ajax({
            url: '/request/past_list?from_date=' + encodeURIComponent($('#from_date').val()) + '&to_date=' + encodeURIComponent($('#to_date').val())
        }).success(function (data) {
            if (data) {
                $('#requests_list').html(data);
                window.can_click = false;
            }
        });
    }, false);

    jQuery(document).on('ajax:complete', '#past_list_form[data-remote]', function (e, e2) {
        if (e2.readyState == 4) {
            $('#requests_list').html(e2.responseText);
        }
    });

    jQuery(document).on('ajax:complete', '.modal form[data-remote]', function (e, e2) {
        if (e2.readyState == 4) {
            if (e2.responseJSON && e2.responseJSON.status == 'ok') {
                var js = e2.responseJSON;
                if (js.email != null) {
                    $('.usr_email').val(js.email);
                    $('.usr_email_html').html(js.email);
                }
                if (js.phone != null) {
                    $('.usr_phone').val(js.phone);
                    $('.usr_phone_html').html(js.phone);
                }
            }
        } else {
            alert(e2.readyState);
        }
    });

    jQuery(document).on('click', '.cancel_request', function () {
        var id = $(this).attr('href').replace('#request_cancel_', '');
        $.ajax({
            url: '/request/cancel/' + id
        }).success(function (data) {
            var errorCanceledBlock = $('#error_canceled_block');

            if (errorCanceledBlock.length) {
                if (data.status == 'ok') {
                    errorCanceledBlock.hide();
                    $('#canceled_block').show();
                    $('#congratulation_block').hide();
                    $('.cancel_row').hide();

                    if (window.driver_info_window != null) {
                        window.driver_info_window.close();
                        window.driver_info_window = null;
                    }
                    clearDirections();
                    clearOverlays();
                } else {
                    $('#congratulation_block').show();
                    errorCanceledBlock.show();
                    errorCanceledBlock.find('p').html('Some error:' + data.message);
                }
            }
        }).fail(function (data) {
            var errorCanceledBlock = $('#error_canceled_block');
            if (errorCanceledBlock.length) {
                errorCanceledBlock.
                    show().
                    find('p').
                    html('Some error:' + data);
            }
        });
        return false;
    });

    jQuery(document).on('click', '#address_import', function () {
        if ($('#address_book_block').is(':visible')) {
            $('#close_address_book').trigger('click');
        } else {
            jQuery('#address_book_block').show().animate({
                left: '34%',
                marginLeft: 0
            });
        }
    });

    jQuery(document).on('click', '#close_address_book', function () {
        jQuery('#address_book_block').animate({
            left: '33%',
            marginLeft: -275
        }, 400, 'swing', function () {
            $(this).hide();
        });
    });

    jQuery(document).on('click', '.address_book_item', function () {
        jQuery('.address_book_item').removeClass('active');
        jQuery(this).addClass('active');
    });

    jQuery(document).on('click', '.pickup_link', function () {
        var address = $(this).parents('div[data-address]').attr('data-address');
        var from = jQuery('#Request_from');
        window.recheck_validators(function () {
            from.val(address);
        });

        from.focus();
        from.blur();
    });

    jQuery(document).on('click', '.dest_link', function () {
        var address = $(this).parents('div[data-address]').attr('data-address');
        var to = jQuery('#Request_to_0');
        to.val(address);
        to.focus();
        to.blur();
    });

    jQuery(document).on('click', '.show_menu', function () {
        jQuery('#left_menu').animate({
            left: '15px'
        });
    });
    jQuery(document).on('click', '.close_menu', function () {
        jQuery('#left_menu').animate({
            left: '-15%'
        });
    });

    jQuery("#left_menu").swipe({
        /**
         * @param event
         * @param phase
         * @param direction
         * @abstract [distance]
         * @abstract [duration]
         * @abstract [fingers]
         * @returns {*}
         */
        swipeStatus: function (event, phase, direction) {
            if (phase == "move" && direction == "left") {
                jQuery('.close_menu').trigger('click');
                return false;
            }
            return event;
        }
    });

    function hideErrors(inputs) {
        $(inputs).
            addClass('valid').
            parents('.field_with_errors').removeClass('field_with_errors');

        for (var i in inputs) {
            if (!inputs.hasOwnProperty(i)) {
                continue;
            }
            var id = $(inputs[i]).attr('id');
            var error = $('#popup_' + id + '_error');
            if (error.length) {
                error.remove();
            }
        }
    }

    function checkFutureVehicle() {
        var dateSome = window.get_trip_date_time();
        var response = $.ajax({
            url: '/check/vehicle/' + dateSome.getTime() / 1000,
            async: false
        });

        return !(response.status == 404 || response.responseJSON.status == 'error');
    }

    function showFutureVehicle() {
        if (checkFutureVehicle()) {
            for (var i = window.only_future_vehicle.length - 1; i > -1; i--) {
                var input = $('#Request_vehicle_id_' + window.only_future_vehicle[i]);
                if (input.length) {
                    input.parents('.vehicle_type').show();
                }
            }
        } else {
            hideFutureVehicle();
        }
    }

    function hideFutureVehicle() {
        for (var i = window.only_future_vehicle.length - 1; i > -1; i--) {
            var input = $('#Request_vehicle_id_' + window.only_future_vehicle[i]);
            if (input.length) {
                input.parents('.vehicle_type').hide();
            }
        }
    }

    function isFutureRequest() {
        return $('.request_type_buttons input[type=radio]:checked').val() == 'future';
    }

    jQuery(document).on('change', '.request_type_buttons input[type=radio]', function () {
        var future_date = jQuery('.future_date'), input;
        if (jQuery(this).val() == 'future') {

            future_date.show();
            future_date.find('input').disableClientSideValidations();
            future_date.find('input').enableClientSideValidations();

            showFutureVehicle();

            var inputs = $('#passengers').find('input');
            inputs.disableClientSideValidations();
            hideErrors(inputs);
        } else {
            $('#passengers').find('input').enableClientSideValidations();
            future_date.hide();
            future_date.find('input').disableClientSideValidations();
            hideFutureVehicle();
            if ($('[name="Request[vehicle_id]"]:checked:visible').length == 0) {
                $($('[name="Request[vehicle_id]"]')[0]).attr('checked', 'checked');
            }
        }
    });

    function checkCancelTime(timer) {
        var id = $(timer).attr('id').replace('cancel_time_', '');
        var fail = function () {
            $(timer).hide().parent().hide()
        };
        $.ajax({
            url: '/request/before_cancel_time/' + id
        }).success(function (data) {
            if (data && data.status == 'ok') {
                var diff = data.time || 0;
                if (diff > 0) {
                    var minutes = Math.floor(diff / 60);
                    var seconds = Math.floor(diff % 60);
                    $(timer).html(str_pad(minutes, 2) + ':' + str_pad(seconds, 2))
                } else {
                    fail();
                }
            } else {
                fail();
            }
        });
    }

    function cancels() {
        var timers = $('.cancel_time:visible');
        var i = timers.length - 1;
        while (i > -1) {
            checkCancelTime(timers[i]);
            --i;
        }

        setTimeout(cancels, 1000);
    }

    setTimeout(cancels, 1000);

    jQuery(document).on('change', '#Request_params_recommend', function () {
        if ($(this).prop('checked')) {
            $('#passengers').show().find('input').enableClientSideValidations();
        } else {
            $('#passengers').hide();
        }
    });

    jQuery(document).on('change', '.charge_credit_card input[type=checkbox]', function () {
        if ($(this).prop('checked')) {
            $('.charge_credit_card_attention').show();
        } else {
            $('.charge_credit_card_attention').hide();
        }
    });

    /**
     * @param element
     * @param [center]
     */
    function load_trip_info(element, center) {
        if (typeof center == "undefined") {
            center = true;
        }

        var id = $(element).attr('data-id');
        if (window.cur_trip_id !== null && id != window.cur_trip_id) {
            return;
        }
        $.ajax({
            url: '/request/' + id
        }).success(function (data) {

            if (window.cur_trip_id !== null && id != window.cur_trip_id) {
                return;
            }

            if (data && data.status && data.status == "ok") {
                if (data.coordinates[0] != null && data.coordinates[1] != null) {
                    var length = data.coordinates.length - 1;
                    window.current_to_points = length;
                    window.current_to = [];
                    window.from = {
                        geometry: {location: (new google.maps.LatLng(data.coordinates[0].lat, data.coordinates[0].lng))},
                        formatted_address: data.coordinates[0].name
                    };

                    for (var i = 1; i <= length; i++) {
                        window.current_to[i - 1] = {
                            geometry: {location: (new google.maps.LatLng(data.coordinates[i].lat, data.coordinates[i].lng))},
                            formatted_address: data.coordinates[i].name
                        };
                    }

                    window.to = {
                        geometry: {location: (new google.maps.LatLng(data.coordinates[length].lat, data.coordinates[length].lng))},
                        formatted_address: data.coordinates[length].name
                    };
                    window.direction(center);
                }

                if (data.add_info && data.add_info.driver) {
                    var driver = data.add_info.driver;
                    var request = data.add_info.request;

                    var latLng = new google.maps.LatLng(driver.coordinates.lat, driver.coordinates.lng);

                    var array = window.putMarker(latLng, '', defaults.DRIVER_ICON, 'driver');

                    window.driver_marker = array[0];

                    if (window.driver_info_window == null) {
                        var html = $('#driver_popup').html();
                        html = html.
                            replace(/__DRIVER_NAME__/ig, driver.name).
                            replace(/__CAR_TYPE__/ig, driver.car_type).
                            replace(/__NOTES__/ig, request.notes).
                            replace(/__ETA__/ig, request.eta).
                            replace(/__DATE__/ig, request.date).
                            replace(/__IMG__/ig, '<img src="' + driver.car.url + '" style="margin: 20px;"/>').
                            replace(/__NAME__/ig, driver.car.name).
                            replace(/__DESC__/ig, driver.car.desc).
                            replace(/__id__/ig, driver.id).
                            replace(/__RATE__/ig, request.rate);

                        var myOptions = {
                            content: html, disableAutoPan: false, maxWidth: 0, pixelOffset: new google.maps.Size(40, -90), zIndex: null, closeBoxMargin: "10px 2px 2px 2px", closeBoxURL: "", infoBoxClearance: new google.maps.Size(1, 1), isHidden: false, pane: "floatPane", enableEventPropagation: false
                        };
                        window.driver_info_window = new InfoBox(myOptions);
                    }

                    google.maps.event.addListener(window.driver_marker, 'click', function () {
                        if (window.driver_info_window_opened) {
                            window.driver_info_window.close();
                            window.driver_info_window_opened = false;
                        } else {
                            window.driver_info_window.open(Gmaps.map.serviceObject, window.driver_marker);
                            window.driver_info_window_opened = true;
                        }
                    });
                }

                window.cur_trip_id = id;
                window.timeout_id = setTimeout(
                    function () {
                        load_trip_info(element, false);
                    }, 3000);
            }
        });
    }

    jQuery(document).on('click', '.request_item', function () {
        if ($(this).hasClass('active')) {
            return;
        }
        $('.request_item.active').removeClass('active');
        $(this).addClass('active');


        window.clearDirections();
        window.clearOverlays();
        window.cur_trip_id = $(this).attr('data-id');

        if (window.driver_info_window != null) {
            window.driver_info_window.close();
            window.driver_info_window = null;
            window.driver_info_window_opened = false;
        }
        if (window.driver_marker != null) {
            window.driver_marker.setMap(null);
            window.driver_marker = null;
        }
        if (window.timeout_id != null) {
            clearTimeout(window.timeout_id);
            window.timeout_id = null;
        }

        load_trip_info(this);
    });

    jQuery(document).on('click', '#add_destination', window.add_way_point);

    jQuery(document).on('click', '.favorite_star', function () {
        var parent = $(this).parent();
        if (parent.hasClass('exist')) {
            return false;
        }

        var input = $(parent).find('input');
        var address = input.val();
        if (address == '') {
            return false;
        }

        var city = input.attr('data-city');
        var street = input.attr('data-street');
        var lat = input.attr('data-lat');
        var lng = input.attr('data-lng');
        var name = input.attr('data-name');

        $(this).attr('data-address', address);

        window.add_favorite(this, city, street, lat, lng, name);
        return true;
    });

    jQuery(document).on('change', '.address_select', function () {
        //window.change_address(this);
    });
    jQuery(document).on('blur', '.address_select', function () {
        //window.change_address(this);
    });

    jQuery(document).on('click', '.cancel_button', function () {
        var id = $(this).attr('id').replace('request_cancel_', '');

        $.ajax({
            url: '/request/cancel/' + id
        }).success(function (data) {
            if (data && data.status && data.status == 'ok') {
                jQuery('#request_id_' + id).slideUp('slow');

                if (window.driver_info_window != null) {
                    window.driver_info_window.close();
                    window.driver_info_window = null;
                }
                clearDirections();
                clearOverlays();
            }
        });

        return false;
    });

    jQuery(document).on('click', '.settings_edit_link', function () {
        var nav = $('#account_settings').find('.menu.nav');

        nav.find('li').removeClass('active');

        nav.find('a[href="' + $(this).attr('href') + '"]').closest('li').addClass('active');
    });

    jQuery(document).on('click', '#add_more_emails', function () {
        if (window.referrers_email > 9) {
            return false;
        }

        var html = $('#referrer_email_template').html();
        html = html.replace(/__i__/gi, window.referrers_email);
        window.referrers_email++;
        $(this).parents('.row').before(html);
        var min_height = parseInt($(this).parents('.modal-content').css('min-height'), 10);
        min_height += 75;
        if (window.referrers_email > 9) {
            $(this).parents('.row').hide();
            min_height -= 35;
        }
        $(this).parents('.modal-content').css('min-height', min_height + 'px');
        return true;
    });


    jQuery(document).on('click', '.delete_favorite', function () {
        window.remove_favorite($(this).attr('data-id'));
    });
    jQuery(document).on({
        mouseenter: function () {
            $('.popover_driver_info').show();
        }, mouseleave: function () {
            $('.popover_driver_info').hide();
        }}, '.show_driver_info');

    $(document).on('click', '#send_notification', function () {
        var request_id = $('#request_id').val();
        var data = [];

        $('.notify:visible').each(function (index, element) {
            var id = $(element).attr('data-id');
            var type = $(element).hasClass('notify_phone') ? 'phone' : 'email';
            data[id] = {type: type, value: $(element).val()}
        });

        $.ajax({
            url: '/request/notify',
            method: "POST",
            data: {id: request_id, data: data}
        }).success(function (data) {
            if (data.status == 'error') {
                $('#errors_block').show().find('p').html(' Error: ' + data.message);
            } else {
                $('#errors_block').hide();
            }
        }).fail(function () {
            $('#errors_block').show().find('p').html('Error with saving phone notifications ');
        });
    });

    init_datepickers(false, window.current_begin_date);
    trasnformDate();
    initialDateTime();
    init_anchor();

    var $Requestdate = $('#Request_date');
    if ($Requestdate.length) {
        var date = new Date();
        $Requestdate.attr('placeholder', Helper.formatted_datetime(date));
    }
});