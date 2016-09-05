;(function($){

    $.fn.tabs = function(){

         return this.each(function() {
 
            var element = $(this);

            function getActiveLi(el){
                var element  = el;
                var liLength = element.has('li a.active').length;
                var selector = (liLength !== 0) ? 'li a.active' : 'li:first a';
                return element.find(selector).attr('href');
            }

            function showTab(element, tabId){
                element.find('.tab').hide();
                element.find(tabId).fadeIn(500);
            }

            function checkTab(element){
                element.find('li').on('click', function(e){
                    element.find('li a').removeClass('active');
                    var tab = $(this).find('a').attr('href');
                    $(this).find('a').addClass('active');
                    showTab(element, tab)
                    // e.find('a').preventDefault();
                });
            }

            function init(element){
                showTab( element, getActiveLi(element) );
                checkTab( element );
            }

            init(element);
        });
    };

}(jQuery));