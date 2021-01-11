////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////

// Video Player Events
function videoPlayEvent(logId) {
  let videoLesson = $("#video-player-window"),
  lessonData = videoLesson.data(),
  playerType = (lessonData.hasOwnProperty('vimeoInitialized'))? 'Vimeo' : 'DaCast';

  ahoy.track('Video Play', {'lesson': lessonData.lessonName, 'course': lessonData.courseName, 'log_id': logId, 'player': playerType });
  // dataLayer.push({'event':'videoAction', 'video_name': lessonData.lessonName,
  //   'course_name': lessonData.courseName, 'video_action':'Play'});
}
function videoFinishedEvent() {
  let videoLesson = $("#video-player-window"),
  lessonData = videoLesson.data(),
  playerType = (lessonData.hasOwnProperty('vimeoInitialized'))? 'Vimeo' : 'DaCast';

  ahoy.track('Video Finished', {'lesson': lessonData.lessonName, 'course': lessonData.courseName,
    'log_id': logId, 'player': playerType });
}

// Quiz Events
function quizStartEvent() {
  let quizWindow = $("#quiz-window"),
    lessonData = quizWindow.data();

  ahoy.track('Quiz Start', lessonData);
  // dataLayer.push({'event':'quizAction', 'quiz_name': lessonData.lessonName,
  //   'course_name': lessonData.courseName, 'quiz_action':'Start'});
}

function quizFinishEvent() {
  let quizResultsWindow = $("#quiz-results-window"),
    lessonData = quizResultsWindow.data();

  ahoy.track('Quiz Finish', lessonData);
  // dataLayer.push({'event':'quizAction', 'quiz_name': lessonData.lessonName,
  //   'course_name': lessonData.courseName, 'quiz_result': lessonData.result,
  //   'quiz_action':'Finish'});
}

// Notes Events
function notesStartEvent() {
  let notesWindow = $("#notes-window"),
      lessonData = notesWindow.data();

  ahoy.track('Notes Start', lessonData);
  // dataLayer.push({
  //   'event': 'notesAction',
  //   'notes_name': lessonData.lessonName,
  //   'course_name': lessonData.courseName,
  //   'notes_action': 'Start'
  // });
}

function notesFinishEvent() {
  let notesWindow = $("#notes-window"),
      lessonData = notesWindow.data();

  ahoy.track('notes Finish', lessonData);
  // dataLayer.push({
  //   'event': 'notesAction',
  //   'notes_name': lessonData.lessonName,
  //   'course_name': lessonData.courseName,
  //   'notes_action': 'Finish'
  // });
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
function planOptionSelect(e) {
  ahoy.track('Subscription Plan Select', e);
}

function providerOptionSelect(e) {
  ahoy.track('Payment Provider Select', e);
}

function subscriptionCreation(e) {
  let status = e.status,
    id = e.subscription_id;
  ahoy.track('Create Subscription', {'status': status, 'id': id});
}

function onBoardingClick(e) {
  let data = e.dataset;
  ahoy.track('Onboarding Click', data);
}


////////////////////////////////////////////////
// Listeners
////////////////////////////////////////////////


$(document).ready(function(){

  // Track all page loads
  ahoy.track('Page View', { url: document.URL, title: document.title, referer: document.referrer, flash: $('#flash_message').text() });

  $(".card.resource-card").on( "click", function() {
    courseResourceClick(this)
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

  $(".onboarding-select").on( "click", function() {
    onBoardingClick(this)
  });

});
