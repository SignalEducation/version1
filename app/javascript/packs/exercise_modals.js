import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import ExhibitsModal from '../components/exercises/ExhibitsModal.vue'
import fullscreen from "vue-fullscreen";
import * as VueWindow from '@hscmap/vue-window';
import VModal from 'vue-js-modal';

Vue.use(BootstrapVue);
Vue.use(fullscreen);
Vue.use(VueWindow);
Vue.use(VModal);

document.addEventListener('DOMContentLoaded', () => {
  const exhibitsList = document.getElementById('exhibits-list-component');

  if (exhibitsList != null) {
    (() =>
      new Vue({
        el: exhibitsList,
        data: {
          scenarioId: exhibitsList.dataset.scenarioId,
          cbeId: exhibitsList.dataset.cbeId,
        },
        render: h => h(ExhibitsModal),
      }))();
  }
});
