(function ($) {
  $(function () {
    window.need_check_blur = true;
    if(typeof window.steps_blocks === "undefined") {
      window.steps_blocks = {
        1: [window.resource_name + '_first_name', window.resource_name + '_last_name', window.resource_name + '_phone'],
        3: [window.resource_name + '_email', window.resource_name + '_password', window.resource_name + '_password_confirmation'],
        4: [window.resource_name + '_credit_card', window.resource_name + '_cvv', window.resource_name + '_credit_card_date', window.resource_name + '_zip_code']
      };
    }
    if(typeof window.alt_steps_blocks === "undefined") {
      window.alt_steps_blocks = {};
    }

    if (typeof window.user_step == "undefined") {
      window.user_step = 1;
    }
    if (typeof window.input_steps == "undefined") {
      window.input_steps = {};
    }

    for (var step in window.steps_blocks) {
      if (!window.steps_blocks.hasOwnProperty(step)) { continue; }
      var blocks = window.steps_blocks[step];
      for (var i in blocks) {
        if (!blocks.hasOwnProperty(i)) { continue; }
        var block = blocks[i];
        window.input_steps[block] = step;
        $(document).on('blur', '#' + block, function () {
          if (!window.need_check_blur) {
            return;
          }
          var step2 = parseInt(window.input_steps[$(this).attr('id')], 10);
          window.need_check_blur = false;
          if (window.checkStep(step2)) {
            window.nextStep(next_step(step2));
          }
          window.need_check_blur = true;
        });
      }
    }

    jQuery(".options_selector ul li").click(function() {
      var titleElements = [this, jQuery(this).siblings().first()];
      var allElements = jQuery.merge(titleElements, jQuery(".options_selector_content > div"));

      jQuery.map(allElements, function(element){
        jQuery(element).toggleClass("selected");
      });

    });

    function prev_step(step) {
      var prev = 0;
      for(var i in window.steps_blocks) {
        if(i == step) {
          return prev;
        }
        prev = i;
      }
      return prev;
    }

    function next_step(step) {
      var flag = false;
      for(var i in window.steps_blocks) {
        if (flag) { return i; }
        if(i == step) { flag = true; }
      }
      return false;
    }

    function checkBlocks(blocks) {
      var flag;
      for (var i in blocks) {
        if (!blocks.hasOwnProperty(i)) { continue; }
        if(typeof flag === "undefined") { flag = true; }
        var block = blocks[i];
        var element = $('#' + block);
        if (window.need_check_blur) {
          window.need_check_blur = false;
          element.focus();
          element.blur();
          window.need_check_blur = true;
        }
        if (!element.hasClass('valid')) {
          flag = false;
        }
      }
      return flag;
    }

    window.checkStep = function (step) {
      var blocks = window.steps_blocks[step];
      var alt_blocks = window.alt_steps_blocks[step] || {};
      var flag = checkBlocks(blocks);
      var alt_flag = checkBlocks(alt_blocks);

      return flag || alt_flag;
    };

    window.nextStep = function (next_step) {
      if (window.steps_blocks[next_step] == null) { return; }
      for (var i in window.steps_blocks[next_step]) {
        if (!window.steps_blocks[next_step].hasOwnProperty(i)) { continue; }

        $('#' + window.steps_blocks[next_step][i]).enableClientSideValidations();
      }
      $('.step[data-step=' + (prev_step(next_step)) + ']').removeClass('step_active').addClass('step_done').addClass('step_hidden');
      var step = $('.step[data-step=' + next_step + ']');
      step.addClass('step_active').removeClass('step_hidden');
      step.find('input[type="text"], input[type="email"]')[0].focus();
      window.user_step = next_step;
    };

    window.prevStep = function(prev_step_var) {
      for(var i = window.user_step; i > prev_step_var; i = prev_step(i)) {
        $('.step[data-step=' + i + ']').removeClass('step_active').removeClass('step_done').addClass('step_hidden');
      }
      $('.step[data-step=' + prev_step_var + ']').addClass('step_active').removeClass('step_done').removeClass('step_hidden');
      window.user_step = prev_step_var;
    };

    $('.step').addClass('step_hidden');
    $('.step[data-step=' + window.user_step + ']').removeClass('step_hidden').addClass('step_active');

    var steps = $('.steps'),
      control = $('.steps_control'),
      navigation = $('.step_navigation');

    navigation.find('.step_next').on('click', function () {
      var next_step = parseInt($(this).attr('data-to-step'));
      if (window.checkStep(prev_step(next_step))) {
        window.nextStep(next_step);
      }
    });

    navigation.find('.step_prev').on('click', function () {
      var prev_step = parseInt($(this).attr('data-to-step'));
      window.prevStep(prev_step);
    });

    control.find('.step').on('click', function() {
      if ($(this).hasClass('step_active')) {
        return false;
      }

      var step = parseInt($(this).attr('data-step'), 10);
      if (!step) {
        return false;
      }

      if (next_step(window.user_step) == step) {
        if (window.checkStep(window.user_step)) {
          window.nextStep(step);
        }
      } else if(step < window.user_step) {
        window.prevStep(step);
      }
      return true;
    });

    var controlPosTop = control.offset().top;
    $(window).scroll(function() {
      var wintop = $(window).scrollTop();
      if (wintop > controlPosTop) {
        control.css({ "position":"fixed", top: '10px' });
      } else {
        control.css({ "position":"static" });
      }
    });

    if(window.user_step) {
      window.nextStep(window.user_step);
    }

    var new_user_form = $('#new_user');
    if(new_user_form.length > 0) {

      var businessMode = $('#business_mode');
      if (businessMode.length > 0) {
        businessMode.val($('#card_info_option').hasClass('selected') ? 'CC' : 'Net_Terms');
      }

      new_user_form.submit(function(e) {
        if (typeof window.form_valid == "undefined") {
          window.form_valid = true;
        }
        if(!window.form_valid) {
          return false;
        }
      });
    }
  });
})(jQuery);

