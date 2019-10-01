import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import store from '../store';
import router from '../router';

// ##### CBE #####
//
// Admin View
//
import CbeAdmin from '../components/cbe/admin/Home';
import CbeEdit from '../components/cbe/admin/Edit';
//
// User View
//
import CbeHome from '../components/cbe/Home';
// ##############

Vue.use(BootstrapVue);

document.addEventListener('DOMContentLoaded', () => {
  const cbes_new = document.getElementById('cbes-new-view');
  if (cbes_new != null) {
    new Vue({
      store,
      el: cbes_new,
      components: { CbeAdmin },
      render: (h) => h(CbeAdmin),
    });
  }

  const cbes_show = document.getElementById('cbes-show-view');
  if (cbes_show != null) {
    new Vue({
      store,
      el: cbes_show,
      components: { CbeEdit },
      render: (h) => h(CbeEdit),
    });
  }

  const cbe_front = document.getElementById('cbe-front-view');
  if (cbe_front != null) {
    new Vue({
      store,
      router,
      el: cbe_front,
      data: {
        cbe_id: cbe_front.dataset.id,
        user_id: cbe_front.dataset.userId,
      },
      render: (h) => h(CbeHome),
    });
  }

  router.replace('/')
});
