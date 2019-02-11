$(document).ready(function(){

    $('.courses-nav .nav-tabs .nav-link').on('click', function(){
        $(this).addClass('active show');
        $(this).parent().siblings().children().removeClass('active show');

    });

    hash = window.location.hash;
    elements = $('a[href="' + hash + '"]');
    if (elements.length === 0) {
        let selectedTab = $(".courses-nav a:first");
        selectedTab.click();
    } else {
        elements.click();
    }

});
