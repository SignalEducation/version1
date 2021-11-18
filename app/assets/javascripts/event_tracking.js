////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////
function courseStepLoaded(type) {
  if (typeof analytics !== "undefined") {
    switch (type) {
      case "Video":
        videoStepLoaded();
        break;
      case "Quiz":
        quizStepLoaded();
        break;
      case "Notes":
        noteStepLoaded();
        break;
      case "Practice Questions":
        practiceQuestionStepLoaded();
        break;
      case "Constructed Response":
        constructedResponseLoaded();
        break;
      default:
        analytics.track("Course Step Loaded");
    }
  }
}

function videoStepLoaded() {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    playerType = typeof player !== "undefined" ? "Vimeo" : "DaCast",
    videoData = { stepType: "Video", player: playerType };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Loaded", properties);
  }
}

function quizStepLoaded() {
  let quizWindow = $("#quiz-window"),
    lessonData = quizWindow.data(),
    quizData = { stepType: "Quiz" };
  let properties = $.extend({}, lessonData, quizData);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Loaded", properties);
  }
}

function noteStepLoaded() {
  let notesWindow = $("#notes-window"),
    lessonData = notesWindow.data(),
    noteData = { stepType: "Note" };
  let properties = $.extend({}, lessonData, noteData);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Loaded", properties);
  }
}

function constructedResponseLoaded() {
  let crWindow = $("#constructed-response-start-screen"),
    properties = crWindow.data();

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Loaded", properties);
  }
}

function practiceQuestionStepLoaded() {
  let pqWindow = $("#practice-question-window"),
    properties = pqWindow.data(),
    type = { stepType: "PracticeQuestion" };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Loaded", data);
  }
}

// Video Player Events
function videoFinishedEvent(
  autoPlay,
  playbackRate,
  duration,
  duration_percent
) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    playerType = typeof player !== "undefined" ? "Vimeo" : "DaCast",
    videoData = {
      stepType: "Video",
      player: playerType,
      playBackRate: playbackRate,
      autoPlay: autoPlay,
    };
  let properties = $.extend({}, stepData, videoData);

  /*if (typeof analytics !== "undefined") {
    analytics.track("Course Step Completed", properties);
  }*/
  sendClickEventToSegment("watched_duration_video", {
    email: email,
    video_name: properties.stepName,
    video_duration: duration,
    video_duration_percentage: duration_percent,
  });
}

// Quiz Events
function quizFinishEvent() {
  let quizResultsWindow = $("#quiz-results-window"),
    properties = quizResultsWindow.data();

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Completed", properties);
  }
}

// Notes Events
function notesStartEvent(pageCount) {
  let notesWindow = $("#notes-window"),
    lessonData = notesWindow.data(),
    noteData = { stepType: "Note", notesPageCount: pageCount };
  let properties = $.extend({}, lessonData, noteData);

  /*if (typeof analytics !== "undefined") {
    analytics.track("Course Step Started", properties);
  }*/
}

function notesFinishEvent(pageCount) {
  let notesWindow = $("#notes-window"),
    lessonData = notesWindow.data(),
    noteData = { stepType: "Note", notesPageCount: pageCount };
  let properties = $.extend({}, lessonData, noteData);

  /*if (typeof analytics !== "undefined") {
    analytics.track("Course Step Completed", properties);
  }*/
}

function notesDownloadEvent(type) {
  if (typeof analytics !== "undefined") {
    if (type === "note") {
      let notesWindow = $("#notes-window"),
        properties = notesWindow.data();

      analytics.track("Course Step Note Downloaded", properties);
    } else {
      let resourceWindow = $("#resource-window"),
        properties = resourceWindow.data();

      analytics.track("Course Resource Downloaded", properties);
    }
  }
}

function constructedResponseStarted() {
  let crWindow = $("#constructed-response-area"),
    properties = crWindow.data(),
    type = { stepType: "ConstructedResponse" };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Started", data);
  }
}

function constructedResponseCompleted() {
  let crWindow = $("#constructed-response-area"),
    properties = crWindow.data(),
    type = { stepType: "ConstructedResponse" };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Completed", data);
  }
}

function practiceQuestionStarted() {
  let pqWindow = $("#practice-question-window"),
    properties = pqWindow.data(),
    type = { stepType: "PracticeQuestion" };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Started", data);
  }
}

function practiceQuestionCompleted() {
  let pqWindow = $("#practice-question-window"),
    properties = pqWindow.data(),
    type = { stepType: "PracticeQuestion" };
  let data = $.extend({}, properties, type);

  if (typeof analytics !== "undefined") {
    analytics.track("Course Step Completed", data);
  }
}

function videoPlayerPaused(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { player: "Vimeo", playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Paused", properties);
  }
}

function videoPlayerResumed(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { player: "Vimeo", playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Play", properties);
  }
}

function videoPlayerSeeked(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { player: "Vimeo", playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Progress Skipped", properties);
  }
}

function videoVolumeChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = { changeType: "Volume Change", player: "Vimeo", playerData };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Settings Changed", properties);
  }
}

function videoPlaybackRateChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = {
      changeType: "Playback Rate Change",
      player: "Vimeo",
      playerData,
    };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Settings Changed", properties);
  }
}

function videoFullScreenChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = {
      changeType: "Fullscreen Change",
      player: "Vimeo",
      playerData,
    };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Settings Changed", properties);
  }
}

function videoQualityChange(playerData) {
  let videoLesson = $("#video-player-window"),
    stepData = videoLesson.data(),
    videoData = {
      changeType: "Playback Quality Change",
      player: "Vimeo",
      playerData,
    };
  let properties = $.extend({}, stepData, videoData);

  if (typeof analytics !== "undefined") {
    analytics.track("Video Settings Changed", properties);
  }
}

function exerciseFileDownload() {
  const edWindow = $("#exercise-download-window");
  let properties = edWindow.data();

  if (typeof analytics !== "undefined") {
    analytics.track("Exercise File Downloaded", properties);
  }
}

function exerciseSubmissionUpload() {
  const euWindow = $("#exercise-upload-window");
  let properties = euWindow.data();

  if (typeof analytics !== "undefined") {
    analytics.track("Exercise Submission Uploaded", properties);
  }
}

function exerciseResultsDownload() {
  const erWindow = $("#exercise-results-window");
  let properties = erWindow.data();

  if (typeof analytics !== "undefined") {
    analytics.track("Exercise Results Downloaded", properties);
  }
}

function cbeLoaded(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("CBE Loaded", data);
  }
}

function cbeStarted(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("CBE Started", data);
  }
}

function cbeSubmitted(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("CBE Submitted", data);
  }
}

// Course Show Page Events
function courseResourceClick(properties) {
  if (typeof analytics !== "undefined") {
    analytics.track("Course Resource Clicked", properties);
  }
}

function courseResourceCompleted(properties) {
  if (typeof analytics !== "undefined") {
    analytics.track("Course Resource Completed", properties);
  }
}

// Payment Checkout Page Events
function showAllPlans(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("Payment Page - Show All Plans Clicked", data);
  }
}

function planOptionSelect(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("Payment Page - Plan Changed", data);
  }
}

function providerOptionSelect(data, type) {
  if (typeof analytics !== "undefined") {
    switch (type) {
      case "paypal":
        analytics.track("PayPal Form Area Clicked", data);
        break;
      case "stripe":
        analytics.track("Stripe Form Area Clicked", data);
        break;
      default:
        analytics.track("PayPal Form Area Clicked", data);
    }
  }
}

function stripeFormFocus(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("Payment Page - Card Field Clicked", data);
  }
}

function couponFieldFocus(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("Payment Page - Coupon Field Clicked", data);
  }
}

function couponFieldExit(data) {
  if (typeof analytics !== "undefined") {
    analytics.track("Payment Page - Coupon Entered", data);
  }
}

function stripeSubmit(data) {
  if (typeof analytics !== "undefined") {
    let provider = { paymentProvider: "stripe" };
    let properties = $.extend({}, data, provider);

    analytics.track("Payment Page - Payment Initiated", properties);
  }
}

function paypalSubmit(data) {
  if (typeof analytics !== "undefined") {
    let provider = { paymentProvider: "payPal" };
    let properties = $.extend({}, data, provider);

    analytics.track("Payment Page - Payment Initiated", properties);
  }
}

function zendeskClick() {
  if (typeof analytics !== "undefined") {
    analytics.track("Customer Service Icon Clicked");
  }
}

function onBoardingStartClick(e) {
  let data = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Get Started Clicked", data);
  }
}

function onBoardingLevelClick(e) {
  let data = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Onboarding Level Clicked", data);
  }
}

function onBoardingCourseClick(e) {
  let data = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Onboarding Course Clicked", data);
  }
}

function onBoardingBackClick(e) {
  let data = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Onboarding Back Button Clicked", data);
  }
}

function onBoardingSkipClick(e) {
  let data = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Onboarding Skip Button Clicked", data);
  }
}

function onboardingExitEvent(e) {
  let properties = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Onboarding Exit", properties);
  }
}

function onboardingCTAClicked(e) {
  let properties = e.dataset;
  if (typeof analytics !== "undefined") {
    analytics.track("Onboarding CTA Clicked", properties);
  }
}

function setCookie_Banner(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
  var expires = "expires=" + d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}
function getCookie_Banner(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(";");
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == " ") {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function sendClickEventToSegment(event_name, properties) {
  let isUTMDataAvailable = false;
  let utmParams = {};
  let utmDataProperties = {};
  if (window.sessionStorage.getItem("utmObj") !== null) {
    isUTMDataAvailable = true;
    utmParams = JSON.parse(window.sessionStorage.getItem("utmObj"));
  }
  if (isUTMDataAvailable) {
    utmDataProperties = { utmParams };
  }
  const allProperties = Object.assign(
    {
      eventSentAt: new Date().toISOString(),
    },
    properties,
    gaBaseProperties(),
    getPageUrl(),
    baseProperties(),
    utmDataProperties
  );
  if (typeof analytics !== "undefined") {
    analytics.track(event_name, allProperties);
  }
}

// Get Base properties

function gaBaseProperties() {
  return { category: "Engagement Web" };
}

function getPageUrl() {
  return { pageUrl: window.location.href };
}
function isMobile() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  );
}
function baseProperties() {
  var deviceType = "";
  var userAgent = navigator.userAgent,
    platform = navigator.platform,
    macosPlatforms = ["Macintosh", "MacIntel", "MacPPC", "Mac68K"],
    windowsPlatforms = ["Win32", "Win64", "Windows", "WinCE"],
    iosPlatforms = ["iPhone", "iPad", "iPod"],
    os = null;

  if (macosPlatforms.includes(platform)) {
    os = "OS X";
  } else if (iosPlatforms.includes(platform)) {
    os = "iOS";
  } else if (windowsPlatforms.includes(platform)) {
    os = "Windows";
  } else if (/Android/.test(userAgent)) {
    os = "Android";
  } else if (!os && /Linux/.test(platform)) {
    os = "Linux";
  }

  isMobile() ? (deviceType = "mobile") : (deviceType = "desktop");

  return { clientOs: os, deviceType: deviceType, platform: userAgent };
}

function getFileAttributes(node) {
  const element = document.getElementById(node);
  if (element.hasAttributes()) {
    return {
      userId: element.getAttribute("userId"),
      email: element.getAttribute("email"),
      hasValidSubscription: element.getAttribute("hasValidSubscription"),
      isEmailVerified: element.getAttribute("isEmailVerified"),
      preferredExamBodyId: element.getAttribute("preferredExamBodyId"),
      isLoggedIn: element.getAttribute("isLoggedIn"),
      sessionId: element.getAttribute("sessionId"),
      fileName: element.getAttribute("file_name"),
      moduleName: element.getAttribute("moduleName"),
      courseName: element.getAttribute("courseName"),
      programName: element.getAttribute("programName"),
    };
  }
}

////////////////////////////////////////////////
// Listeners
////////////////////////////////////////////////

$(document).ready(function() {
  $("#menu > div > div > h3.sidebar-title").on("click", function() {
    onboardingExitEvent(this);
  });

  $("#sidebar-bottom-menu > div > a").on("click", function() {
    onboardingExitEvent(this);
  });

  $(".onboarding-get-start").on("click", function() {
    onBoardingStartClick(this);
  });

  $(".onboarding-level").on("click", function() {
    onBoardingLevelClick(this);
  });

  $(".onboarding-course").on("click", function() {
    onBoardingCourseClick(this);
  });

  $(".onboarding-back-button").on("click", function() {
    onBoardingBackClick(this);
  });

  $(".onboarding-skip-button").on("click", function() {
    onBoardingSkipClick(this);
  });

  $(".upgrade-arrow").on("click", function() {
    onboardingCTAClicked(this);
  });

  // Zendesk Customer Support Open Event
  var waitForZopim = setInterval(function() {
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

  $("#exercise-file-download").on("click", function() {
    exerciseFileDownload();
  });

  $("#exercise-results-download").on("click", function() {
    exerciseResultsDownload();
  });

  $(".resource-card").on("click", function() {
    courseResourceClick(this.dataset);
  });
});
