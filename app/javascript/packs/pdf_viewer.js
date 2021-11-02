import Vue from 'vue';
import fullscreen from 'vue-fullscreen'
import BootstrapVue from 'bootstrap-vue';
import VModal from 'vue-js-modal';
import VueModal from '../components/VueModal.vue';
import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
import ModalViewer from '../components/pdf/ModalViewer.vue';
import NotesViewer from '../components/pdf/NotesViewer.vue';

Vue.use(BootstrapVue);
Vue.use(fullscreen)
Vue.use(Loading);
Vue.use(VueModal);
Vue.use(VModal);

const mountViewerElement = (element, data, component) =>
new Vue({
  el: element,
    data: {
      fileUrl: data.fileUrl,
      fileId: data.fileId,
      fileName: data.fileName,
      fileDownload: (data.fileDownload == 'true'),
      courseId: data.courseId,
      stepLogId: data.stepLogId,
      courseName: data.courseName,
      examBodyId: data.examBodyId,
      examBodyName: data.examBodyName,
      preferredExamBodyId: data.preferredExamBodyId,
      preferredExamBodyName: data.preferredExamBodyName,
      hasValidSubscription: data.hasValidSubscription,
      banner: data.banner,
      onboarding: data.onboarding
    },
    render: h => h(component)
  });

document.addEventListener('DOMContentLoaded', () => {
  // Course Resources Modal Window
  while (document.getElementsByClassName('pdf-files-elements').length !== 0) {
    let element = document.getElementsByClassName('pdf-files-elements').item(0);
    (() => mountViewerElement(element, element.dataset, ModalViewer))();
  }

  // Course Notes Viewer
  const courseNotesElement = document.getElementById('course-notes-reader');
  (() => mountViewerElement(courseNotesElement, courseNotesElement && courseNotesElement.dataset, NotesViewer))();
});
