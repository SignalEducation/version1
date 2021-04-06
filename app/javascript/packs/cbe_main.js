/* eslint-disable */

import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import fullscreen from "vue-fullscreen";
import store from '../store';
import router from '../router';
import * as VueWindow from '@hscmap/vue-window';
import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
// ##### CBE #####
//
// Admin View
//
import CbeAdmin from '../components/cbe/admin/Home.vue';
import CbeEdit from '../components/cbe/admin/Edit.vue';
//
// User View
//
import CbeHome from '../components/cbe/UserHome.vue';
// ##############

Vue.use(BootstrapVue);
Vue.use(fullscreen);
Vue.use(Loading);
Vue.use(VueWindow);

const mountCbeElement = (element, theComponent) =>
  new Vue({
    store,
    el: element,
    components: { theComponent },
    render: h => h(theComponent)
  });

document.addEventListener('DOMContentLoaded', () => {
  const cbeNew = document.getElementById('cbes-new-view');
  if (cbeNew != null) {
    (() => mountCbeElement(cbeNew, CbeAdmin))();
  }

  const cbeEdit = document.getElementById('cbes-edit-view');
  if (cbeEdit != null) {
    (() => mountCbeElement(cbeEdit, CbeEdit))();
  }

  const cbeFront = document.getElementById('cbe-front-view');
  if (cbeFront != null) {
    (() => new Vue({
      store,
      router,
      el: cbeFront,
      data: {
        cbe_id: cbeFront.dataset.id,
        cbe_name: cbeFront.dataset.cbeName,
        user_id: cbeFront.dataset.userId,
        exercise_id: cbeFront.dataset.exerciseId,
        product_name: cbeFront.dataset.productName,
        product_id: cbeFront.dataset.productId,
        course_name: cbeFront.dataset.courseName,
        course_id: cbeFront.dataset.courseId,
        exam_body_name: cbeFront.dataset.examBodyName,
        exam_body_id: cbeFront.dataset.examBodyNameId,
      },
      render: (h) => h(CbeHome),
    }))();

    // Loading introduction pages as root when home load.
    router.replace(`/introductions/${cbeFront.dataset.introductionId}`);
  }
});
