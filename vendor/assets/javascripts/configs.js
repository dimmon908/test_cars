jQuery(function() {
  jQuery(document).on('change', '.config_key_input', function() {
    var id = $(this).attr('data_id');
    var value = $(this).val();
    $.post('/admin/config/' + id + '.json', {id: id, value: value}).
      done(function(data){
        console.log(data);
      });
  });
});