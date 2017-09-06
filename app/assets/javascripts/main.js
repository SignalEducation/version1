//After loading all HTML
$(document).ready(function(){


    //detects mouse
    $("body").one("mousemove",function(){
        $("body").addClass("hasMouse");
    });


    //mobile menu
    $("#menu .mobile").click(function(){
        $("body").toggleClass("menu-open");
    });


    //header form
    // Added code to open form i
    $("#free .s-get").click(function(){
        var $a = $(this);
        if ($a.hasClass("form-open")) {
            $a.parents("form").submit();
        } else {
            $a.addClass("form-open");
            $("#free .form").slideDown(300);
        }
        return false;
    });


    //basic form validation
    $("form").submit(function(){
        var ok = true;
        var $form = $(this);
        var msg = "";
        $form.find(".validate").each(function(){
            if ($(this).val()=="") {
                var l = $(this).attr("placeholder");
                if (l===undefined || l=="") l = $(this).parents(".form-select").find(".form-control").attr("placeholder");
                if (l!="") msg = msg + '\n- '+l;
                ok = false;
            }
        });
        if (!ok) alert("Please check the following fields:\n"+msg);
        return ok;
    });


    //video lightbox
    $(".lb-video").tosrus();


    //anchor click
    $(".anchor").click(function(){
        var $a = $(this);
        var id = $a.attr("href");
        var $id = $(id);
        if ($id.length>0) {
            var t = $id.offset().top;
            $("html, body").animate({ scrollTop: t },1000);
            return false;
        } else {
            return true;
        }
    });


});



//After load all content
$(window).load(function(){


    //match sizes
    $("#homeblog .post").matchHeight();
    $("#plans .plan .topbox").matchHeight();
    $("#plans .plan .details").matchHeight();
    $("#plans .plan .box").matchHeight();
    $("#footer .fmenu").matchHeight();
    $("#reviews2 .box").matchHeight();


    //sync review slideshows
    if ($("#reviews").length>0) {
        $('#reviews .slides').on('cycle-before', function(e,o) {
            var index = o.nextSlide;
            $("#reviews .bgslides").cycle(index);
        });
    }


    //countdown
    if ($('#countdown .timer').length>0) {
        var dt = $("#countdown .timer").data("date");
        $('#countdown .timer').countdown(dt, function(event) {
            $(this).html(event.strftime('<div><span class="n">%D</span><span class="l">days</span></div> <div><span class="n">%H</span><span class="l">hrs</span></div> <div><span class="n">%M</span><span class="l">mins</span></div> <div><span class="n">%S</span><span class="l">secs</span></div>'));
        });
    }


    //loading
    $("#loading").fadeOut(600);

});
