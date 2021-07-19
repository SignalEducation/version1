import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import fullscreen from 'vue-fullscreen'
import MainView from '../components/practiceQuestions/MainView.vue';
import * as VueWindow from '@hscmap/vue-window';
import VModal from 'vue-js-modal';
import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';

Vue.use(BootstrapVue);
Vue.use(fullscreen)
Vue.use(Loading);
Vue.use(VueWindow);
Vue.use(VModal);

const mountViewerElement = (element, data, component) =>
new Vue({
  el: element,
    data: {
      practiceQuestionId: data.practiceQuestionId,
      stepLogId: data.stepLogId,
      stepLogs: JSON.parse(data.stepLogs)
    },
    render: h => h(component)
  });

document.addEventListener('DOMContentLoaded', () => {
  // Practice Question Viewer
  const courseNotesElement = document.getElementById('practice-question-viewer');
  (() => mountViewerElement(courseNotesElement, courseNotesElement.dataset, MainView))()
});
