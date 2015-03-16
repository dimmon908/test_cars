jQuery(function() {
  jQuery(document).on('ajax:complete', 'form[data-remote]', function(e, e2) {
    if (e2.responseJSON && e2.responseJSON.status == 'ok') {
       $('#activate_success').show();
       $('#activate_fail').hide();
    } else {
      $('#activate_success').hide();
      $('#activate_fail').show();
      if (e2.responseJSON && e2.responseJSON.message) {
        $('#activate_fail p').html(e2.responseJSON.message);
      }
    }
  });
});