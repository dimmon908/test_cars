$(function() {
  var switcher = $('.switcher');

  switcher.find('.switcher_tab').on('click', function() {
    if (!$(this).hasClass('switcher_tab_active')) {
      switcher.find('.switcher_tab').toggleClass('switcher_tab_active');
      $('.account').toggle();
    }
  });
});