/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'cbe_main' %> (and
// <%= stylesheet_pack_tag 'cbe_main' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue';
import splitPane from 'vue-splitpane'
import App from '../App'
import Show from '../Show'
import store from '../store/index'

import VueRouter from 'vue-router';
import BootstrapVue from 'bootstrap-vue';

Vue.component('split-pane', splitPane);
Vue.use(VueRouter);
Vue.use(BootstrapVue);


document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('cbes-new-view');
  if (element != null) {
    const vue = new Vue({
      store,
      el: element,
      template: '<App/>',
      components: { App },
      render: (h) => h(App),
    });
  }
});

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('cbes-show-view');
  if (element != null) {
    const vue = new Vue({
      store,
      el: element,
      template: '<Show/>',
      components: { Show },
      render: (h) => h(Show),
    });
  }
});
