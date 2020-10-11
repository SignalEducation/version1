import Vue from 'vue';
import fullscreen from 'vue-fullscreen'
import MainView from '../components/practiceQuestions/MainView.vue';

Vue.use(fullscreen)

const mountViewerElement = (element, data, component) =>
new Vue({
  el: element,
    data: {
      practiceQuestionId: data.practiceQuestionId
    },
    render: h => h(component)
  });

document.addEventListener('DOMContentLoaded', () => {
  // Practice Question Viewer
  const courseNotesElement = document.getElementById('practice-question-viewer');
  (() => mountViewerElement(courseNotesElement, courseNotesElement.dataset, MainView))()
});
