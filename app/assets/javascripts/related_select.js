function getMatchesAsOptionTags(arrayOfChildren, targetValue, currentValue) {
  var result = "<option value=''>Select...</option>";
  for(var counter = 0; counter < arrayOfChildren.length; counter++) {
    if (arrayOfChildren[counter][2] == targetValue) {
      if (currentValue == arrayOfChildren[counter][0]) {
        result += "<option selected='selected' value='" + arrayOfChildren[counter][0] + "'>" + arrayOfChildren[counter][1] + "</option>";
      } else {
        result += "<option value='" + arrayOfChildren[counter][0] + "'>" + arrayOfChildren[counter][1] + "</option>";
      }
    }
  }
  return result;
}


function watchChildSelect(childDomObject, parentDomObject, arrayOfChildren) {
  var childSelect = $('#' + childDomObject);
  var parentSelect = $('#' + parentDomObject);
  parentSelect.on('change', function() {
    childSelect.html( getMatchesAsOptionTags(arrayOfChildren, parentSelect.val(), childSelect.val() ) );
    childSelect.change();
  });
}
