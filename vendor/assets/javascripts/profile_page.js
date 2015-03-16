$(function() {
  window.input_validate_status = {};

  /**
   * @param link
   * @param selector
   * @param [callback]
   */
  function send_ajax(link, selector, callback) {
    $.ajax({
      url: link,
      headers: {
        Accept : "q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"
      }
    }).done(function(data) {
      $(selector).html(data);

      if (typeof callback === "function") { callback(data); }
    });
  }

  $(document).on("ajax:success", 'form[data-remote]', function(e, e2) {
    $(this).find('.success').show();
    $(this).find('.fail').hide();
  });

  $(document).on("ajax:error", 'form[data-remote]', function(e, e2) {
    $(this).find('.success').hide();
    $(this).find('.fail').show();
    if (typeof e2.responseJSON !== "undefined") {
      $(this).find('.fail p').html(e2.responseJSON.message);
    } else {
      $(this).find('.fail p').html('Something wrong');
    }
  });

  $(document).on('focus', 'form input[data-validate]', function() {
    var id = $(this).attr('id');
    if (id != '') {
      var error_id  = '#popup_' + id + '_error';

      if (typeof input_validate_status[id] === "undefined") { input_validate_status[id] = {}; }

      if ($(error_id).length > 0) {
        input_validate_status[id]['error'] = true;
        input_validate_status[id]['changed'] = true;
        input_validate_status[id]['popup'] = error_id;
        $(error_id).hide();
        $(this).parent().removeClass('field_with_errors');
      } else {
        input_validate_status[id]['error'] = false;
        input_validate_status[id]['changed'] = true;
      }
    }
  });

  $(document).on('change', 'form input[data-validate]', function() {
    var id = $(this).attr('id');
    if (id != '') {
      if (typeof input_validate_status[id] === "undefined") { input_validate_status[id] = {}; }

      input_validate_status[id]['changed'] = false;
    }
  });

  $(document).on('blur', 'form input[data-validate]', function() {
    var id = $(this).attr('id');
    if (id != '') {

      if (typeof input_validate_status[id] === "undefined") { input_validate_status[id] = {}; }

      var error_id  = '#popup_' + id + '_error';
      if ($(error_id).length > 0 && input_validate_status[id]['changed']) {
        $(error_id).show();
        $(this).parent().addClass('field_with_errors');
      }
    }
  });

  $(document).on('focus', '#user_password_confirmation', function() {
    $(this).removeClass('none_focused');
  });

  $(document).on('ajax:success', '#billing a[data-remote]', function(e, e2) {
    if (e2 != '') { $('#credit_card_block').html(e2); }
  });

  $(document).on('ajax:success', '#billing a[data-remote].delete_card', function(e, e2) {
    send_ajax('/cards', '#credit_card_list');
  });

  $(document).on('ajax:complete', '#new_card[data-remote]', function(e, e2) {
    if (e2.readyState == 4) {
      var data = e2.responseJSON;
      var body = $(this).parents('.modal-body');
      if (data) {
        if (data.status == 'ok') {
          body.find('.success').show();
          body.find('.update_success, .fail').hide();
          send_ajax('/cards', '#credit_card_list');
          send_ajax('/card/' + data.id, '#credit_card_block');
        } else {
          body.find('.fail').show();
          body.find('.fail').html(get_message(data.message));
          body.find('.update_success, .success').hide();
        }
      } else {
        body.find('.fail').show();
        body.find('.fail').html('Some error');
        body.find('.update_success, .success').hide();
      }
    }
  });

  $(document).on('ajax:complete', '#edit_card[data-remote]', function(e, e2) {
    if (e2.readyState == 4) {
      var data = e2.responseJSON;
      var body = $(this).parents('.modal-body');
      if (data) {
        if (data.status == 'ok') {
          body.find('.update_success').show();
          body.find('.success, .fail').hide();
          send_ajax('/cards', '#credit_card_list');
        } else {
          body.find('.fail').show();
          body.find('.fail').html(get_message(data.message));
          body.find('.update_success, .success').hide();
        }
      } else {
        body.find('.fail').show();
        body.find('.fail').html('Some error');
        body.find('.update_success, .success').hide();
      }
    }
  });

  $(document).on('ajax:complete', '#personal_info_edit', function(e, e2) {
    if (e2.readyState == 4) {
      $('#image_uploader').isLoading("hide").html('Success load');

      var data = false;
      if (e2.responseJSON) { data = e2.responseJSON; }
      if (e2.responseText) { try { data = JSON.parse(e2.responseText); } catch(e) {} }

      if (data && data.img) { $('.user_avatar').attr('src', data.img); }
    } else {

      $('#image_uploader').isLoading("hide").html('Error with load');
    }
  });

  $(document).on('ajax:remotipartSubmit', '#personal_info_edit', function() {
    $('#image_uploader').isLoading({
      text:       "Loading",
      position:   "inside",
      disableOthers: [
        $(this).parent().parent().parent().find('button')
      ]
    });
  });

  $(document).on('click', '#show_card', function() {
    var block = $('#card_info_block');
    if (block.length && !block.is('visible')) {
      block.show();

      var blocks = window.steps_blocks[4] || {};
      for (var i in blocks) {
        if (!blocks.hasOwnProperty(i)) { continue; }
        $('#' + blocks[i]).
          disableClientSideValidations().
          enableClientSideValidations();
      }
    }

    $('#net_terms_block').hide();
  });
});