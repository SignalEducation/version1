import Vue from 'vue';
import ModalViewer from '../components/pdf/ModalViewer.vue';
import NotesViewer from '../components/pdf/NotesViewer.vue';

const mountViewerElement = (element, data, component) =>
  new Vue({
    el: element,
    data: {
      fileName: data.fileName,
      fileUrl: data.fileUrl,
      courseId: data.courseId,
      stepLogId: data.stepLogId
    },
    render: h => h(component)
  });

document.addEventListener('DOMContentLoaded', () => {
  // Course Resources Modal Window
  const pdfFilesElements = document.getElementsByClassName('pdf-files-elements');

   Array.prototype.map.call(pdfFilesElements, element => (
     (() => mountViewerElement(element, element.dataset, ModalViewer))()
  ));

  // Course Notes Viewwer
  const courseNotesElement = document.getElementById('course-notes-reader');
  (() => mountViewerElement(courseNotesElement, courseNotesElement.dataset, NotesViewer))()
});
