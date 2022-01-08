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

  sendClickEventToSegment("watched_duration_video", {
    email: email,
    video_name: properties.stepName,
    video_duration: duration,
    video_duration_percentage: duration_percent,
  });
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

function createBasePropertiesSegment(properties) {
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

  return allProperties;
}

// Get Base properties

function gaBaseProperties() {
  return { category: "Engagement Web" };
}

function getPageUrl() {
  var page_url = window.location.href.replace(/'/g, "%27");
  return { pageUrl: page_url };
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
      lessonName: element.getAttribute("file_name"),
      moduleName: element.getAttribute("moduleName"),
      courseName: element.getAttribute("courseName"),
      programName: element.getAttribute("programName"),
    };
  }
}
