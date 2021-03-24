////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////

// Video Player Events
function videoPlayEvent(autoPlay) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    playerType = (stepData.hasOwnProperty('vimeoInitialized'))? 'Vimeo' : 'DaCast',
    videoData = { 'type': 'Video', 'player': playerType, 'autoPlay': autoPlay };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Started', properties);
  }
}
function videoFinishedEvent(autoPlay, playbackRate) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    playerType = (stepData.hasOwnProperty('vimeoInitialized'))? 'Vimeo' : 'DaCast',
    videoData = { 'type': 'Video', 'player': playerType, 'playBackRate': playbackRate , 'autoPlay': autoPlay };
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

function notesDownloadEvent(type) {
  if (typeof analytics !== 'undefined') {
    if (type === 'note') {
      let notesWindow = $("#notes-window"),
        properties = notesWindow.data();

      analytics.track('Course Step Note Downloaded', properties);
    } else {
      let resourceWindow = $("#resource-window"),
        properties = resourceWindow.data();

      analytics.track('Course Resource Downloaded', properties);
    }
  }
}

function constructedResponseStartLoaded() {
  let crWindow = $("#constructed-response-start-screen"),
    properties = crWindow.data();

  if (typeof analytics !== 'undefined') {
    analytics.track('Constructed Response Start Loaded', properties);
  }
}

function constructedResponseStarted() {
  let crWindow = $("#constructed-response-area"),
    properties = crWindow.data(),
    type = { 'type': 'ConstructedResponse' };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Started', data);
  }
}

function constructedResponseCompleted() {
  let crWindow = $("#constructed-response-area"),
    properties = crWindow.data(),
    type = { 'type': 'ConstructedResponse' };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Completed', data);
  }
}

function practiceQuestionStarted() {
  let pqWindow = $("#practice-question-window"),
    properties = pqWindow.data(),
    type = { 'type': 'PracticeQuestion' };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Started', data);
  }
}

function practiceQuestionCompleted() {
  let pqWindow = $("#practice-question-window"),
    properties = pqWindow.data(),
    type = { 'type': 'PracticeQuestion' };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Step Completed', data);
  }
}

function videoPlayerPaused(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);


  if (typeof analytics !== 'undefined') {
    analytics.track('Video Paused', properties);
  }
}

function videoPlayerResumed(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Video Play', properties);
  }
}

function videoPlayerSeeked(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Video Progress Skipped', properties);
  }
}

function videoVolumeChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'type': 'Volume Change', 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Video Settings Changed', properties);
  }
}

function videoPlaybackRateChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'type': 'Playback Rate Change', 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Video Settings Changed', properties);
  }
}

function videoFullScreenChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'type': 'Fullscreen Change', 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Video Settings Changed', properties);
  }
}

function videoQualityChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { 'type': 'Volume Change', 'player': 'Vimeo', playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== 'undefined') {
    analytics.track('Video Settings Changed', properties);
  }
}

function exerciseFileDownload() {
  let properties = $("#exercise-download-window");

  if (typeof analytics !== 'undefined') {
    analytics.track('Exercise File Downloaded', properties);
  }
}

function exerciseSubmissionUpload() {
  let properties = $("#exercise-upload-window");

  if (typeof analytics !== 'undefined') {
    analytics.track('Exercise Submission Uploaded', properties);
  }
}

function exerciseResultsDownload() {
  let properties = $("#exercise-results-window");

  if (typeof analytics !== 'undefined') {
    analytics.track('Exercise Results Downloaded', properties);
  }
}

function cbeLoaded(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('CBE Loaded', data);
  }
}

function cbeStarted(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('CBE Started', data);
  }
}

function cbeSubmitted(data) {
  if (typeof analytics !== 'undefined') {
    analytics.track('CBE Submitted', data);
  }
}

// Course Show Page Events
function courseResourceClick(properties) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Course Resource Clicked', properties);
  }
}

function courseResourceExternalClick() {
  let properties = $("#resource-card");

  if (typeof analytics !== 'undefined') {
    analytics.track('Course Resource Clicked', properties);
  }
}

function courseResourceCompleted(properties) {
  if (typeof analytics !== 'undefined') {
    analytics.track('Course Resource Completed', properties);
  }
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

  $("#exercise-file-download").on( "click", function() {
    exerciseFileDownload()
  });

  $("#exercise-results-download").on( "click", function() {
    exerciseResultsDownload()
  });

  $(".resource-card").on( "click", function() {
    courseResourceExternalClick()
  });

});
