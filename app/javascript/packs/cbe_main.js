import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import App from '../App';
import Show from '../Show';
import store from '../store';
import router from '../router';


// CBE FRONT
import CbeHome from '../components/cbe/Home';

Vue.use(BootstrapVue);

document.addEventListener('DOMContentLoaded', () => {
  const cbes_new = document.getElementById('cbes-new-view');
  if (cbes_new != null) {
    const vue = new Vue({
      store,
      el: cbes_new,
      template: '<App/>',
      components: { App },
      render: (h) => h(App),
    });
  }

  const cbes_show = document.getElementById('cbes-show-view');
  if (cbes_show != null) {
    const vue = new Vue({
      store,
      el: cbes_show,
      template: '<Show/>',
      components: { Show },
      render: (h) => h(Show),
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
