
function collapseFunc(isOpen) {
    if(isOpen) {
      if (document.getElementById("console-wrapper-sidebar") != null) {
        document.getElementById("console-wrapper-sidebar").classList.toggle("console-wrapper-sidebar-left");
      }
      if (document.getElementById("sidebar-wrapper-student") != null) {
        document.getElementById("sidebar-wrapper-student").classList.toggle("sidebar-wrapper-student-width");
      }
      if (document.getElementById("practice-question-window") != null) {
        document.getElementById("practice-question-window").classList.toggle("practice-question-window-width-mgn-left");
      }
      if (document.getElementById("sidebar-btn-collapse-elem") != null) {
        document.getElementById("sidebar-btn-collapse-elem").classList.toggle("activate-collapse");
      }
      if (document.getElementById("sidebar") != null) {
        document.getElementById("sidebar").classList.toggle("sidebar-hide");
      }
      if (document.getElementById("sidebar-steps-count") != null) {
        document.getElementById("sidebar-steps-count").classList.toggle("sidebar-hide");
      }
      if (document.getElementById("sidebar-bottom-menu") != null) {
        document.getElementById("sidebar-bottom-menu").classList.toggle("sidebar-hide");
      }
      if (document.getElementById("arrow-collapse") != null) {
        document.getElementById("arrow-collapse").classList.toggle("arrow-collapse-animation");
      }
      if (document.getElementById("sidebar-right-content") != null) {
        document.getElementById("sidebar-right-content").classList.toggle("sidebar-right-content-width-mgn-left");
      }
      if (document.getElementById("course-right-show-elem-vid") != null) {
        document.getElementById("course-right-show-elem-vid").classList.toggle("course-right-show-elem-vid-top");
      }
      if (document.getElementById("#courses-show-external-banner") != null) {
        document.getElementById("#courses-show-external-banner").classList.toggle("course-show-external-banner-open");
      }
      if (document.getElementById("constructed-response-window") != null) {
        document.getElementById("constructed-response-window").classList.toggle("constructed-response-window-shrunk");
      }
      isOpen = false;
    } else {
      if (document.getElementById("console-wrapper-sidebar") != null) {
        document.getElementById("console-wrapper-sidebar").classList.toggle("console-wrapper-sidebar-left");
      }
      if (document.getElementById("sidebar-wrapper-student") != null) {
        document.getElementById("sidebar-wrapper-student").classList.toggle("sidebar-wrapper-student-width");
      }
      if (document.getElementById("practice-question-window") != null) {
        document.getElementById("practice-question-window").classList.toggle("practice-question-window-width-mgn-left");
      }
      if (document.getElementById("sidebar-btn-collapse-elem") != null) {
        document.getElementById("sidebar-btn-collapse-elem").classList.toggle("activate-collapse");
      }
      if (document.getElementById("sidebar") != null) {
        document.getElementById("sidebar").classList.toggle("sidebar-hide");
      }
      if (document.getElementById("sidebar-steps-count") != null) {
        document.getElementById("sidebar-steps-count").classList.toggle("sidebar-hide");
      }
      if (document.getElementById("sidebar-bottom-menu") != null) {
        document.getElementById("sidebar-bottom-menu").classList.toggle("sidebar-hide");
      }
      if (document.getElementById("arrow-collapse") != null) {
        document.getElementById("arrow-collapse").classList.toggle("arrow-collapse-animation");
      }
      if (document.getElementById("sidebar-right-content") != null) {
        document.getElementById("sidebar-right-content").classList.toggle("sidebar-right-content-width-mgn-left");
      }
      if (document.getElementById("course-right-show-elem-vid") != null) {
        document.getElementById("course-right-show-elem-vid").classList.toggle("course-right-show-elem-vid-top");
      }
      if (document.getElementById("#courses-show-external-banner") != null) {
        document.getElementById("#courses-show-external-banner").classList.toggle("course-show-external-banner-open");
      }
      if (document.getElementById("constructed-response-window") != null) {
        document.getElementById("constructed-response-window").classList.toggle("constructed-response-window-shrunk");
      }
      isOpen = true;
    }

  }