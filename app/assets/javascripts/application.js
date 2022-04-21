// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require js-routes
//= require turbolinks
//= require_tree .

jQuery(document).on('turbolinks:load', function() {
  jQuery('a.create-exam').on('click',function(){
    var exam_type = jQuery(this).data('exam-type')

    switch (exam_type) {
      case 'gold':
      case 'silver':
        url = Routes.exam_histories_path()
        break;
      case 'marathon':
        url = Routes.marathon_index_path()
        break;
    }

    jQuery.ajax({
      url:  url,
      type: 'POST',
      data: {exam_type: exam_type}
    });
  });

  jQuery('div.option').on('click', function(){
    var ribbon = jQuery(this).find('.ui-ribbon-wrapper');
    var option_id = jQuery(this).data('option-id');
    var hidden_field = jQuery(this).find("input[id^='user_answer_answer']");

    if(ribbon.is(':visible')) {
      ribbon.hide();
      hidden_field.attr('value', '');
    }
    else {
      ribbon.show();
      hidden_field.attr('value', option_id);
    }
  });

  jQuery('.retry').on('click', function() {
    var history_id = jQuery(this).data('history-id')
    jQuery.ajax({
      url: Routes.retry_exam_history_path(history_id),
      type: 'POST'
    })
  });

  history.pushState(null, null, null);

  window.addEventListener("popstate", function() {
    history.pushState(null, null, null);
  });
});
