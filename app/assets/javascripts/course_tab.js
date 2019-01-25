$(document).ready(function(){

    $('.courses-nav a').on('click', function(){
        //$(this).addClass('underline').siblings().removeClass('underline');
    });

    // Prevent browser jump to anchor tag
    if (location.hash) {
        setTimeout(function() {
            window.scrollTo(0, 0);
        }, 1);
    }

    hash = window.location.hash;
    elements = $('a[href="' + hash + '"]');
    if (elements.length === 0) {
        let selectedTab = $(".courses-nav a:first");
        selectedTab.addClass("active").show();
        selectedTab.attr('aria-selected', 'true');
        selectedTab.click();

    } else {
        elements.click();
    }

});
