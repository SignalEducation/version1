$(document).on('ready page:load', function() {

  // see http://johnny.github.io/jquery-sortable/

  // if there is more than one .sorted-table table on a page:
  // - give the table an ID
  // - put the ID as a data-parent property on every <tr> inside <tbody>
  $('.sorted_table').sortable({
    containerSelector: 'table',
    itemPath: '> tbody',
    itemSelector: 'tr',
    handle: 'span.glyphicon.glyphicon-sort',
    placeholder: '<tr class="placeholder"/>',
    onDrop: function (item, container, _super) {
      sendDataToServer(item);
    }
  });

  function sendDataToServer(theItem) {
    var parentTable = $('#' + theItem.attr('data-parent')).first();
    console.log(parentTable);
    if (parentTable.length == 0) {
      console.log('parent table was null');
      parentTable = $('.sorted_table').first();
    }
    var rows = parentTable.find(" tbody > tr"),
      arrayOfIds = [],
      theUrl = parentTable.attr('data-destination');
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
        $("body").removeClass("dragging");
      }
    });
  }

});
