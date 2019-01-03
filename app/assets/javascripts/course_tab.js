$(document).ready(function(){

    $('.course-section-tabs a').on('click', function(){
        $(this).addClass('underline').siblings().removeClass('underline');
    });

    hash = window.location.hash;
    elements = $('a[href="' + hash + '"]');
    if (elements.length === 0) {
        $(".course-section-tabs a:first").addClass("active").show();
        $(".course-section-tabs a:first").click();
    } else {
        elements.click();
    }


});