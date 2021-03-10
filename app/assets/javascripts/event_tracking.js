////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////

// Video Player Events
function videoPlayEvent() {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    playerType = (stepData.hasOwnProperty('vimeoInitialized'))? 'Vimeo' : 'DaCast',
    videoData = { 'type': 'Video', 'player': playerType, autoplay: 'tbc' };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Started', properties);
  }
}
function videoFinishedEvent() {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    playerType = (stepData.hasOwnProperty('vimeoInitialized'))? 'Vimeo' : 'DaCast',
    videoData = { 'type': 'Video', 'player': playerType, autoplay: 'tbc' };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Completed', properties);
  }
}

// Quiz Events
function quizStartEvent() {
  let quizWindow = $("#quiz-window"),
    lessonData = quizWindow.data(),
    quizData = { 'type': 'Quiz' };
  let properties = $.extend({}, lessonData, quizData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Started', properties);
  }
}

function quizFinishEvent() {
  let quizResultsWindow = $("#quiz-results-window"),
    properties = quizResultsWindow.data();

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Completed', properties);
  }
}

// Notes Events
function notesStartEvent() {
  let notesWindow = $("#notes-window"),
      lessonData = notesWindow.data(),
      noteData = { 'type': 'Note' };
  let properties = $.extend({}, lessonData, noteData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Started', properties);
  }
}

function notesFinishEvent() {
  let notesWindow = $("#notes-window"),
    lessonData = notesWindow.data(),
    noteData = { 'type': 'Note' };
  let properties = $.extend({}, lessonData, noteData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Completed', properties);
  }
}

function notesDownloadEvent() {
  let notesWindow = $("#notes-window"),
    properties = notesWindow.data();

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Note Downloaded', properties);
  }
}

// Course Show Nav Events
function titleCourseClick(e) {
  let data = e.dataset;
  ahoy.track('Sidebar Title Course Click', data);
}

function nextCourseClick(e) {
  let data = e.dataset;
  ahoy.track('Next Course Step Click', data);
}

function previousCourseClick(e) {
  let data = e.dataset;
  ahoy.track('Previous Course Step Click', data);
}

function sidebarCourseClick(e) {
  let data = e.dataset;
  ahoy.track('Sidebar Course Step Click', data);
}

function sidebarCollapseClick(e) {
  let data = e.dataset;
  ahoy.track('Sidebar Collapse Click', data);
}

function sidebarNextModuleClick(e) {
  let data = e.dataset;
  ahoy.track('Sidebar Next Module Click', data);
}

// Course Show Page Events
function courseResourceClick(e) {
  let resourceData = e.dataset;

  ahoy.track('Course Resource Click', resourceData);
  // dataLayer.push({'event':'resourceClick', 'resource_name': resourceData.name,
  //   'course_name': resourceData.course_name, 'resource_type': resourceData.type,
  //   'user_permitted': resourceData.allowed});
}

function courseTabClick(e) {
  let data = e.dataset;
  ahoy.track('Course Tab Click', data);
}

function coursePanelClick(e) {
  let data = e.dataset;
  ahoy.track('Course Module Panel Click', data);
}

function courseLessonClick(e) {
  let data = e.dataset;
  ahoy.track('Course Lesson Click', data);
}

// Payment Checkout Page Events
function showAllPlans(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Payment Page - Show All Plans Clicked', data);
  }
}

function planOptionSelect(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Payment Page - Plan Changed', data);
  }
}

function providerOptionSelect(data, type) {
  if (typeof analytics !== 'undefined') {
    switch (type) {
      case 'paypal':
        analytics.track('PayPal Form Area Clicked', data);
        break;
      case 'stripe':
        analytics.track('Stripe Form Area Clicked', data);
        break;
      default:
        analytics.track('PayPal Form Area Clicked', data);
    }
  }
}

function stripeFormFocus(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Payment Page - Card Field Clicked', data);
  }
}

function couponFieldFocus(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Payment Page - Coupon Field Clicked', data);
  }
}

function couponFieldExit(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Payment Page - Coupon Entered', data);
  }
}

function stripeSubmit(data) {
  if (typeof analytics !== 'undefined') {
    let provider = {provider: 'Stripe'};
    let properties = $.extend({}, data, provider);

    analytics.track('Payment Page - Payment Initiated', properties);
  }
}

function paypalSubmit(data) {
  if (typeof analytics !== 'undefined') {
    let provider = {provider: 'PayPal'};
    let properties = $.extend({}, data, provider);

    analytics.track('Payment Page - Payment Initiated', properties);
  }
}

function zendeskClick() {
  if (typeof analytics !== 'undefined') {
    analytics.track('Customer Service Icon Clicked');
  }
}

function onBoardingStartClick(e) {
  let data = e.dataset;
  if (typeof analytics !== 'undefined') {
    analytics.track('Get Started Clicked', data);
  }
}

function onBoardingLevelClick(e) {
  let data = e.dataset;
  if (typeof analytics !== 'undefined') {
    analytics.track('Onboarding Level Clicked', data);
  }
}

function onBoardingCourseClick(e) {
  let data = e.dataset;
  if (typeof analytics !== 'undefined') {
    analytics.track('Onboarding Course Clicked', data);
  }
}

function onBoardingBackClick(e) {
  let data = e.dataset;
  if (typeof analytics !== 'undefined') {
    analytics.track('Onboarding Back Button Clicked', data);
  }
}

function onboardingExitEvent(e) {
  let properties = e.dataset;
  if (typeof analytics !== 'undefined') {
    analytics.track('Onboarding Exit', properties);
  }
}

function onboardingCTAClicked(e) {
  let properties = e.dataset;
  if (typeof analytics !== 'undefined') {
    analytics.track('Onboarding CTA Clicked', properties);
  }
}

////////////////////////////////////////////////
// Listeners
////////////////////////////////////////////////


$(document).ready(function(){

  $("#menu > div > div > h3.sidebar-title").on( "click", function() {
    onboardingExitEvent(this)
  });

  $("#sidebar-bottom-menu > div > a").on( "click", function() {
    onboardingExitEvent(this)
  });

  $("#sidebar-right-content > div > header > div > a.sidebar-nav-btn-lefty").on( "click", function() {
    previousCourseClick(this)
  });

  $("#sidebar-right-content > div > header > div > a.sidebar-nav-btn-right").on( "click", function() {
    nextCourseClick(this)
  });

  $("#step-block > a > .step").on( "click", function() {
    sidebarCourseClick(this)
  });

  $("#sidebar-btn-collapse-elem").on( "click", function() {
    sidebarCollapseClick(this)
  });

  $("#coursesTabs > li.nav-item").on( "click", function() {
    courseTabClick(this)
  });

  $("a.btn.course-module-panel").on( "click", function() {
    coursePanelClick(this)
  });

  $("ul > li > .btn.course-lesson ").on( "click", function() {
    courseLessonClick(this)
  });

  $(".onboarding-get-start").on( "click", function() {
    onBoardingStartClick(this)
  });

  $(".onboarding-level").on( "click", function() {
    onBoardingLevelClick(this)
  });

  $(".onboarding-course").on( "click", function() {
    onBoardingCourseClick(this)
  });

  $(".onboarding-back-button").on( "click", function() {
    onBoardingBackClick(this)
  });

  $(".upgrade-arrow").on( "click", function() {
    onboardingCTAClicked(this)
  });

  // Zendesk Customer Support Open Event
  var waitForZopim = setInterval(function () {
    if (window.$zopim === undefined || window.$zopim.livechat === undefined) {
      return;
    }
    $zopim(function() {
      $zopim.livechat.window.onShow(function(callback) {
        zendeskClick();
      });
    });
    clearInterval(waitForZopim);
  }, 100);

});
