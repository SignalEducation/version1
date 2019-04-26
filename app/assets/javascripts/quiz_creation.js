function deleteFlashQuizAnswer(thing) {
    var theQuestion = $(thing).closest('.question'),
        theAnswer = $(thing).closest('.quiz_answer');

    // ensure there are at least three answers in this question - otherwise, don't delete
    if (theQuestion.find('.quiz_answer').length > 2) {
        var confirmation = confirm("Are you sure?");
        if (confirmation) {
            if (theAnswer.find('.answer-id').val() == '') {
                theAnswer.remove();
            } else {
                theAnswer.find('.answer-destroy').val('1');
                theAnswer.hide();
            }
        }
    } else {
        alert("Sorry, you can't delete this answer - there must be at least two answers for each question.");
    }
}

$(document).on('click', '.deleteFlashAnswer', function() {
    deleteFlashQuizAnswer(this);
    return false;
});

