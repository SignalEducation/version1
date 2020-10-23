import Vue from 'vue';
import BootstrapVue from "bootstrap-vue";
import Spreadsheet from '../components/general/Spreadsheet.vue'

Vue.use(BootstrapVue);

const mountViewerElement = (element, data, component) =>
  new Vue({
    el: element,
    data: {
      content: data.spreadsheetContent,
      hidden_field_name: data.fieldName,
      hidden_field_id: data.fieldId,
    },
    render: (h) => h(component),
  });

document.addEventListener("DOMContentLoaded", () => {
  // Course Resources Modal Window
  while (document.getElementsByClassName("spreadsheet_component").length !== 0 ) {
    let element = document.getElementsByClassName("spreadsheet_component").item(0);
    (() => mountViewerElement(element, element.dataset, Spreadsheet))();
  }
});
