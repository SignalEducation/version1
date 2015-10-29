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
    },
    onDragStart: function ($item, container, _super) {
      var offset = $item.offset(),
        pointer = container.rootGroup.pointer;

      adjustment = {
        left: pointer.left - offset.left,
        top: pointer.top - offset.top
      };

      _super($item, container);
    },
    onDrag: function ($item, position) {
      $item.css({
        left: position.left - adjustment.left,
        top: position.top - adjustment.top
      });
    }
  });

  function sendDataToServer(theItem) {
    var parentTable = theItem.parent().parent();
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
      }
    });
    $("body").removeClass("dragging");
  }

});