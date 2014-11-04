$(document).on('ready page:load', function() {

  // see http://johnny.github.io/jquery-sortable/
  $('.sorted_table').sortable({
    containerSelector: 'table',
    itemPath: '> tbody',
    itemSelector: 'tr',
    placeholder: '<tr class="placeholder"/>',
    onDrop: function (item, container, _super) {
      sendDataToServer();
    }
  });

  function sendDataToServer() {
    var rows, arrayOfIds = [];
    rows = $(".sorted_table tbody > tr");
    for (var counter = 0; counter < rows.length; counter++) {
      if (rows[counter].id != '') {
        arrayOfIds.push(rows[counter].id);
      }
    }
    $.ajax({
      type: 'POST', url: window.location.href + '/reorder',
      data: {array_of_ids: arrayOfIds},
      success: console.log('Reordered OK')
    });
  }

});
