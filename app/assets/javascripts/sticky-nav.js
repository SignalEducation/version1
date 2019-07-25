$(window).scroll(function() {
    var scroll = $(window).scrollTop();

    if (scroll >= 1) {
        //clearHeader, not clearheader - caps H
        $(".header").addClass("sticky-nav-border");
    } else if (scroll <= 1) {
        $(".header").removeClass("sticky-nav-border");
    }
});