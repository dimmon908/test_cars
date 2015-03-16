$(document).on 'click', '.date-picker-today', (event) ->
  $(this).parents('.row').find('.datepicker').each (index, element)->
    picker = $(element).data('datetimepicker');
    date = new Date();
    picker.setDate(date);
    $(element).find('input').val(Helper.formatted_date(date))