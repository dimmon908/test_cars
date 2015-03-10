(function($) {
  $(function() {
    function adjaust_background() {
      var bg = $('.landing-page-slider-bg, .row.account .white_bg'),
        width = Math.floor($( window ).width()) - 1;

      if (width < $('body > .container').outerWidth()) {
        return;
      }

      bg.css({
        width: width,
        left: '50%',
        marginLeft: -Math.floor(width / 2)
      });
    }

    adjaust_background();
    $(window).resize(function() {
      adjaust_background();
    });
  });
})(jQuery);