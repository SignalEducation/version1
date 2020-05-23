import Vue from 'vue';
import fullscreen from 'vue-fullscreen'
import ModalViewer from '../components/pdf/ModalViewer.vue';
import NotesViewer from '../components/pdf/NotesViewer.vue';

Vue.use(fullscreen)

const mountViewerElement = (element, data, component) =>
new Vue({
  el: element,
    data: {
      fileUrl: data.fileUrl,
      fileName: data.fileName,
      fileDownload: (data.fileDownload == 'true'),
      courseId: data.courseId,
      stepLogId: data.stepLogId
    },
    render: h => h(component)
  });

document.addEventListener('DOMContentLoaded', () => {
  // Course Resources Modal Window
  while (document.getElementsByClassName('pdf-files-elements').length !== 0) {
    let element = document.getElementsByClassName('pdf-files-elements').item(0);
    (() => mountViewerElement(element, element.dataset, ModalViewer))()
  }

  // Course Notes Viewer
  const courseNotesElement = document.getElementById('course-notes-reader');
  (() => mountViewerElement(courseNotesElement, courseNotesElement.dataset, NotesViewer))()
});
