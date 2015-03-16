jQuery(function() {
  window.link_for_reset = '';
  window.contentId = '';
  var last_modal_url, last_modal_id, double_submited_form = false;
  var open_messages_window = false;
  if (typeof window.currentTab == "undefined" || window.currentTab == null) { window.currentTab = ''; }

  var NAVIGATION_LINKS = {
    dashboard:    '/admin/dashboard',
    map:          '/admin/map',
    requests:     '/admin/request',
    passengers:   '/admin/personal',
    drivers:      '/admin/driver',
    promo_codes:  '/admin/promo_codes',
    companies:    '/admin/business',
    future_rides: '/admin/future_riders',
    admins:       '/admin/admins',
    users:       '/admin/users',
    cars:         '/admin/car/',
    report:       '/admin/reports',
    emails:       '/admin/email',
    sms:          '/admin/sms',
    notification: '/admin/notification',
    configs: '/admin/config'
  };

  var anchor = function() {
    var stripped_url = document.location.toString().split("#");
    if (stripped_url.length > 1) {
      return stripped_url[1];
    }
    return '';
  };

  function handleAnchor(anc) {
    anc = anc || anchor();
    if (anc == 'new') {
      $('#ajax_container').find('a.link_to_new').click();
    }
  }

  function init() {
    var datepicker = $('.datepicker');
    if (datepicker.length) {
      try {
        datepicker.each(function(undex, value) {
          $(value).datetimepicker({
            pickTime: false,
            dateFormat: "yyyy-mm-dd"
          }).on('changeDate', function(e) {
              var input = $(value).find('input');
              var date_str, choosed = e.date;
              if (choosed != null) {
                date_str = choosed.getUTCFullYear() + '-' + str_pad(choosed.getUTCMonth()+1, 2) + '-' + str_pad(choosed.getUTCDate(), 2);
                $(input).val(date_str);
                $(input).change();
              }
          });

          if ($(value).attr('data-date')) {
            var picker = $(value).data('datetimepicker');
            var date = new Date($(value).attr('data-date'));
            picker.setDate(date);
          }

        });
      } catch(e) {}
    }


    var uniformjs = $('.uniformjs');
    if (uniformjs.length) uniformjs.find("select, input, button, textarea").uniform();

    $('form[data-validate]').
      enableClientSideValidations();

    var table = $('.table-filter');
    if (table.length) {
      table.tableFilter();
    }
  }

  /**
   *
   * @param [callback]
   */
  function reloadWindow(callback) {
    send_ajax(last_modal_url, last_modal_id, callback);
  }

  function reloadDesktop(callback) {
    var url = NAVIGATION_LINKS[window.currentTab];
    var query = [];
    var $page = $('#page');
    var $per_page = $('#per_page');
    if ($page.length && $page.val() != '') {
      query.push('page='  + $page.val());
    }
    if ($per_page.length) {
      query.push('per_page=' + $per_page.val());
    }
    if (query.length > 0) {
      url += '?' + query.join('&');
    }

    send_ajax(url, '#ajax_container', callback);
  }

  /**
   * @param link
   * @param selector
   * @param [callback]
   */
  function send_ajax(link, selector, callback, headers) {
    if (typeof headers == "undefined") {
      headers = "q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript";
    }
    $.ajax({
      url: link,
      cache: false,
      headers: { Accept : headers },
      type: 'GET',
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      }
    }).done(function(data) {
      $(selector).html(data);
      init();
      if (typeof callback === "function")
        callback(data);
    }).fail(function(data) {
      if (data.readyState == 4) {
        $(selector).html(data.responseText);
        init();
        if (typeof callback === "function")
          callback(data.responseText);
      }
    });
  }

  /**
   * @param errors_block
   * @param data
   */
  function showError(errors_block, data) {
    if (errors_block.length) {
      errors_block.show();
      var html = '';
      try {
        var errors;

        if (typeof data.message === "string") {
          errors = JSON.parse(data.message);
        } else {
          errors = data.message;
        }

        for(var i in errors) {
          if (!errors.hasOwnProperty(i)) { continue; }

          var error = errors[i];
          html += '<p>' + i + ':   ' + error[0] + '</p>';
        }
      } catch(e) {
        html = data.message;
      }
      errors_block.html(html);
    }
  }

  // Forms functionality
  (function() {

  /**
   * @param data
   * @param close
   */
  function remoteResponder(data, close) {
    var errors_block = $(close).find('.modal-errors');

    if (typeof data != "object") {
      errors_block.show().html('Some error');
      return false;
    }

    if (data.status == 'ok') {
      close.modal('hide');

      if(errors_block.length)
        errors_block.hide();

      if (double_submited_form) {
        reloadWindow();
        double_submited_form = false;
      } else {
        reloadDesktop(function(){$('.modal-backdrop.fade.in').remove();});
      }

    } else {
      showError(errors_block, data);
    }

    return false;
  }


  $(document).on('submit', '.modal-body form', function() {
    if ($(this).attr('data-remote'))
      return false;


    var valuesToSubmit = $(this).serialize();
    var close = jQuery(this).parents('[role="dialog"]');

    jQuery.ajax({
      url: $(this).attr('action'),
      data: valuesToSubmit,
      method: 'POST'
    }).success(function(data) {
        remoteResponder(data, close);
    }).fail(function(data) {
      if (data.readyState == 4) {
        close.modal('hide');
        send_ajax(NAVIGATION_LINKS[window.currentTab], '#ajax_container', function(){$('.modal-backdrop.fade.in').remove();});
      }
    });
    return false;
  });

  $(document).on('click', '.admin-modal .submitForm', function() {
    $(this).parents('.admin-modal').find('form').submit();
  });

  $(document).on('click', 'ul.menu li', function() {
    if ($(this).hasClass('current')) { return; }
    $('ul.menu li.current').removeClass('current');
    $(this).addClass('current');
  });

    $(document).on('click', '.resetForm', function() {
      if(!window.link_for_reset || window.link_for_reset == '') return;
      send_ajax(window.link_for_reset, window.contentId);
    });

  $(document).on('ajax:complete', 'form[data-remote]', function(e, e2) {
    if (e2.readyState == 4) {
      if ($(e.target).attr('data-window-reload')) {
        return;
      }
      var data;
      if(typeof e2.responseJSON != "undefined" && e2.responseJSON != null) {
        data = e2.responseJSON;
      } else {
        try {
          data = JSON.parse(e2.responseText)
        } catch(e) {}
      }
      var close = jQuery(this).parents('[role="dialog"]');
      remoteResponder(data, close);
    }
  });
  })();

  // Change ajax functionality
  (function() {
  $(document).on("ajax:complete", 'a[data-remote]', function(e, e2) {
    if ($(this).attr('data-toggle') == 'modal') {
      if (typeof $(this).attr('data-window-reload') == "undefined") {
        last_modal_id = $(this).attr('data-target') + ' .modal-body';
        last_modal_url = e.target.href;
      } else {
        double_submited_form = true;
      }
      $($(this).attr('data-target')).find('.modal-body').html(e2.responseText);
    } else if ($(this).attr('data-window-reload')) {
        reloadWindow();
    } else if($(this).attr('data-reload')) {
        reloadDesktop();
    } else if ($(this).parents('.list').length) { // Deprecated, For old code
      if ($(this).attr('data-target')) {
        $($(this).attr('data-target')).html(e2.responseText);
      } else {
        $('#modalContent').html(e2.responseText);
      }
    } else { // Deprecated, For old code
      var tab = $(this).attr('data-tab');
      var tab_li = $('li[data-tab="' + tab + '"]');

      if (!$(this).attr('data-ignore-tab') && tab_li.hasClass('current')) { return; }
      $('ul.menu li.current').removeClass('current');
      tab_li.addClass('current');
      window.currentTab = tab;
      $.get('/session/admin_tab/' + tab);

      $('#ajax_container').html(e2.responseText);
    }
    init();
  });

    $(document).on("ajax:beforeSend", 'a[data-remote]', function() {
      $(this).parents('.dropdown.open').removeClass('open');

      if ($(this).attr('data-ignore-tab'))
        return true;

      var tab = $(this).attr('data-tab');
      var tab_li = $('li[data-tab="' + tab + '"]');
      return !tab_li.hasClass('current');
    });
  })();

  // Pagination functionality
  (function() {
  $(document).on('change', '#per_page', function() {
    var tab = $(this).attr('data-tab');
    var value = $(this).val();
    var href = $('li[data-tab="' + tab + '"] a');
    send_ajax(href.attr('href') + '?per_page=' + value, '#ajax_container');
  });

  $(document).on('click', '#addUser', function() {
    send_ajax('/sub_account/new', '#modalContent', function() {window.link_for_reset = '/sub_account/new'; window.contentId = '#modalContent';} );
  });

  $(document).on('click', '.resetForm', function() {
    if(!window.link_for_reset || window.link_for_reset == '') return;
    send_ajax(window.link_for_reset, window.contentId);
  });

  $(document).on('click', '.paginators a', function() {
    var link = $(this).attr('href');
    send_ajax(link, '#ajax_container');
    return false;
  });
  })();

  // Custom listeners
  (function() {
    $(document).on('click', '#addUser', function() {
      send_ajax('/sub_account/new', '#modalContent', function() {window.link_for_reset = '/sub_account/new'; window.contentId = '#modalContent';} );
    });

  $(document).on('change', '#SubAccount_email', function() {});

    $(document).on('change', '.orders_type', function() {
      if ($(this).val() == 1) {
        $('.over_value').show();
      } else {
        $('.over_value').hide();
      }
    });

    $(document).on('click', 'ul.menu li', function() {
      if ($(this).hasClass('current')) { return; }
      $('ul.menu li.current').removeClass('current');
      $(this).addClass('current');
    });
  })();

  // Vehicle rates functionality
  (function() {
  $(document).on('click', '.save_vehicle_rate', function() {
    var element = $(this).parents('tr').find('.config_vehicle_input');

    var id = $(element).attr('data_id');
    var value = $(element).val();
      var response = Helper.async_ajax('/admin/vehicle/' + id + '.json', {id: id, value: value});

    if (response.responseJSON.status == 'ok') {
      $(element).val(response.responseJSON.value);
    }
  });

  $(document).on('click', '.save_vehicle_rates', function() {
    var $perMile = $('#per_mile');
    var $perMinute = $('#per_minute');
    //var $perWaitMinute = $('#per_wait_minute');

    var id = $('#choose_vehicle_id').val();
    var per_mile = $perMile.val();
    var per_minute = $perMinute.val();
    //var per_wait_minute = $perWaitMinute.val();

    var response = Helper.async_ajax(
        '/admin/vehicle/' + id + '/edit.json',
      {
        id: id,
        per_mile: per_mile,
        per_minute: per_minute,
      //  per_wait_minute: per_wait_minute
      }
    );

    if (response.responseJSON.status == 'ok') {
      $perMile.val(response.responseJSON.per_mile);
      $perMinute.val(response.responseJSON.per_minute);
    }
  });

  $(document).on('click', '.edit_vehicle_rate', function() {
    var element = $(this).parents('tr').find('.config_vehicle_input');
    var id = $(element).attr('data_id');
      var response = Helper.async_ajax('/admin/vehicle/' + id + '/edit.json', {}, 'GET');

    if (response.responseJSON.status == 'ok') {
      $('#per_mile').val(response.responseJSON.per_mile);
      $('#choose_vehicle_per_mile').val(response.responseJSON.per_mile);

      $('#per_minute').val(response.responseJSON.per_minute);
      $('#choose_vehicle_per_minute').val(response.responseJSON.per_minute);

      //$('#per_wait_minute').val(response.responseJSON.per_wait_minute);
      //$('#choose_vehicle_per_wait_minute').val(response.responseJSON.per_wait_minute);

      $('#choose_vehicle_id').val(id);
    }
  });

  $(document).on('click', '.reset_vehicle_rate', function() {
    var element = $(this).parents('table').find('.config_vehicle_input');
    var id = $(element).attr('data_id');
      var response = Helper.async_ajax('/admin/vehicle/' + id + '.json', {id: id}, 'GET');

    if (response.responseJSON.status == 'ok') {
      $(element).val(response.responseJSON.value);
    }
  });

  $(document).on('click', '.reset_vehicle_rates', function() {
    $('#per_mile').val($('#choose_vehicle_per_mile').val());
    $('#per_minute').val($('#choose_vehicle_per_minute').val());
    //$('#per_wait_minute').val($('#choose_vehicle_per_wait_minute').val());
  });
  })();

  // Admin messages functionality
  (function() {

    function outputMessages(messages) {
      var html = '';
      var template = $('#notification_template').html();
      for(var cnt = messages.length - 1; cnt > -1; cnt--) {
        if ($('#admin_notify_'  + messages[cnt].id).length) { continue; }
        html += template.
          replace(/__id__/ig, messages[cnt].id).
          replace(/__message__/ig, messages[cnt].body).
          replace(/__readed__/ig, messages[cnt].status == 'new' ? 'notify_new': '')
      }

      if (html != '') {
        template = $('#clear_notifications_template').html();
        html += template.replace(/__template__/, '')
      }

      var messagesWindow = $('#admin_messages_window').find('ul');
      if (messagesWindow.html() == '' && html == '') { html = 'None messages'; }
      messagesWindow.html(html + messagesWindow.html());

      messagesWindow.find('span[data-date]').each(function(index, value) { Helper.reformDate(value); });
    }

    $(document).on('click', '#admin_notify_clear', function() {
      Helper.simple_ajax('/admin/messages/clear_all', {}, function() {$('.admin_notify, #admin_notify_clear').remove();});
    });

    $(document).on('click', '.reply-btn', function() {
      var id = $(this).attr('data-id');
      $('#adminReplyMessage').find('.modal-body').html($('#admin_reply_message_template').html().replace(/_template_/ig, '').replace(/__id__/ig, id));

      var text = $(this).parent().find('.message-text').html();
      var header = text.replace(/\s\-".*"/, ' Wrote:');
      var message = text.match(/\s+\-"(.*)"/)[1];
      $('#adminReplyLabel').html(header);
      $('#driver_message').html("\n\n\t" + message);
    });

    $(document).on('click', '#adminReplyMessage .btn-ok', function() {
      var message = $.trim($("#admin_message").val());
      var errors_block = $('#adminReplyMessage').find('.modal-errors');
      if (message == '') {
        errors_block.html('Sending message should be not empty!!');
        return;
      } else {
        errors_block.val('');
      }
      var $drivermessage = $('#driver_message');
      var id = $(this).attr('data-id');
      Helper.simple_ajax('/admin/messages/' + id  +'/reply', {message: message}, function(data){
        if (data.status == "ok") {
          $drivermessage.val($drivermessage.val() + "\n\n\t" + message);
          $("#admin_message").val('');
        } else {
          showError(errors_block, data);
        }
      });
    });

    $(document).on('click', '.hide-btn', function() {
      var id = $(this).attr('data-id');
      Helper.simple_ajax('/admin/messages/' + id + '/hide', {}, function() {$('#admin_notify_' + id).remove();});
    });

    $(document).on('click', '#admin_messages', function() {
      var messages = $('#admin_messages_window');
      if (open_messages_window) {
        open_messages_window = false;
        messages.hide();
      } else {
        var ul = messages.find('ul');
        if ($('#admin_messages_count').html == '' && ul.html() != '') {
          messages.show();
          open_messages_window = true;
          return false;
        }
        Helper.simple_ajax(ul.html() == '' ? '/admin/messages' : '/admin/messages/new', {}, function(data) {
          if (data && data.status == 'ok') {
            outputMessages(data.data);

            messages.show();
            open_messages_window = true;
          }
        });
      }
      return false;
    });

    $(document).on('mouseover', '.notify_new', function() {
      var element = this;
      var id = $(this).attr('id').replace('admin_notify_', '');
      $.ajax({
        url: '/admin/messages/' + id + '/read',
        success: function() {
          $(element).removeClass('notify_new');
          var cnt_element = $('#admin_messages_count');
          var cnt = parseInt(cnt_element.html(), 10);
          cnt--;
          cnt_element.html(cnt > 0 ? cnt : '');
        }
      });
    });

    (function() {
      var adminMessagesCount = $('#admin_messages_count');

      function getNewMessages(callback) {
        Helper.simple_ajax('/admin/messages/new', {}, function(data) {
          if (data && data.status == 'ok') {
            if (data.data.length > 0) {
              adminMessagesCount.html(data.data.length);
              outputMessages(data.data);
            } else {
              adminMessagesCount.html('');
            }
          }
          if (typeof callback == "function") {callback();}
        });
      }
      function getNewMessagesCount(callback) {
        Helper.simple_ajax('/admin/messages/new/count', {}, function(data) {
          if (data && data.status == 'ok') { adminMessagesCount.html(data.data > 0 ? data.data : ''); }
          if (typeof callback == "function") {callback();}
        });
      }

      if (adminMessagesCount.length > 0) {
        var _callee = arguments.callee;
        var callee = function() {setTimeout(_callee, 10000);};
        if (open_messages_window) {
          getNewMessages(callee);
        } else {
          getNewMessagesCount(callee);
        }
      }
    })();
  })();

  // Custom actions
  (function(anc) {
    function anchor() {
      var stripped_url = document.location.toString().split("#");
      if (stripped_url.length > 1) {
        return stripped_url[1];
      }
      return '';
    }

    anc = anc || anchor();
    if (anc == 'new') { $('#ajax_container').find('a.link_to_new').click(); }
  })();
});