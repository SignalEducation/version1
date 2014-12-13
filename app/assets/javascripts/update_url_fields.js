$(document).on('ready', function() {

  $('.update-my-url').on('change', function() {
    var the_id = '#' +$(this).attr('id') + '_url';
    if ($(the_id).val() == "") {
      $(the_id).val($(this).val().replace(/ |\//g, '-').toLowerCase());
    } else {
      if ($(the_id).parent().hasClass('has-warning')) {} else {
        $(the_id).parent().addClass('has-warning');
        $(the_id).attr('aria-describedby', 'helpBlock');
        $(the_id).parent().append("<span id='helpBlock' class='help-block'>Do you need to update the URL?</span>")
      }
    }
  })

});
