$(document).on('ready page:load', function() {

  // see http://johnny.github.io/jquery-sortable/
  $('.sorted_table').sortable({
    containerSelector: 'table',
    itemPath: '> tbody',
    itemSelector: 'tr',
    handle: 'span.glyphicon.glyphicon-sort',
    placeholder: '<tr class="placeholder"/>',
    onDrop: function (item, container, _super) {
      sendDataToServer();
    }
  });

  function sendDataToServer() {
    var rows = $(".sorted_table tbody > tr"),
        arrayOfIds = [],
        theUrl = $('.sorted_table').attr('data-destination');
    for (var counter = 0; counter < rows.length; counter++) {
      if (rows[counter].id != '') {
        arrayOfIds.push(rows[counter].id);
      }
    }
    $.ajax({
      type: 'POST',
      url: (theUrl || window.location.href) + '/reorder',
      data: {array_of_ids: arrayOfIds},
      success: function() {
        $('tr.dragged').removeClass('dragged').attr('style','');
      }
    });
  }

});
