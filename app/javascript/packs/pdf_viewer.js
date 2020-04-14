import Vue from 'vue';
import ViewerWindow from '../components/pdf/ViewerWindow.vue';

const mountViewerElement = (element, data) =>
  new Vue({
    el: element,
    data: {
      fileName: data.fileName,
      fileUrl: data.fileUrl
    },
    components: {
      ViewerWindow
    },
    render: h => h(ViewerWindow)
  });

document.addEventListener('DOMContentLoaded', () => {
  const pdfFilesElements = document.getElementsByClassName('pdf-files-elements');

   Array.prototype.map.call(pdfFilesElements, element => (
     (() => mountViewerElement(element, element.dataset))()
  ));
});
