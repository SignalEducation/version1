$(document).on('ready', function() {

  $('.update-my-url').on('change blur', function() {
    var the_id = '#' +$(this).attr('id') + '_url';
    if ($(the_id).val() == '') {
      $(the_id).val($(this).val().replace(/ |\//g, '-').toLowerCase());
    } else {
      $(the_id).parent().addClass('');
    }
  })

});
