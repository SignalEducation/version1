/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue'
import Vuex from 'vuex'
import App from '../app'
import splitPane from 'vue-splitpane'
import VeeValidate from 'vee-validate';


Vue.use(Vuex)
Vue.component('split-pane', splitPane);
Vue.use(VeeValidate);


export const store = new Vuex.Store({
    state: {
        currentCBEId: null,
        currentSectionId: null,
        currentSubjectId: null,
        cbeName: '666',
        cbeSection: null,
        cbeTitle: null,
        cbeDecsription: null,
        cbeTimeLimit: null,
        cbeNumberOfAllowablePauses: null,
        cbeTimeLimit: null,
    },

    getters: {
        getCBEName(state, name) {
            // For now we allow Jenny just to remove 
            // one TV at a time.
            return cbeName
          }
    },

    mutations: {
        setCBEName(state, name) {
            // For now we allow Jenny just to remove 
            // one TV at a time.
            state.cbeName  = name
          }
    }

})

document.addEventListener('DOMContentLoaded', () => {
    const el = document.body.appendChild(document.createElement('vueapp'))
    const vue = new Vue({
        store: store,
        el: 'vueapp',
        template: '<App/>',
        components: {App},
        render: h => h(App)
    })

})


// The above code uses Vue without the compiler, which means you cannot
// use Vue to target elements in your existing html templates. You would
// need to always use single file components.
// To be able to target elements in your existing html/erb templates,
// comment out the above code and uncomment the below
// Add <%= javascript_pack_tag 'hello_vue' %> to your layout
// Then add this markup to your html template:
//
// <div id='hello'>
//   {{message}}
//   <app></app>
// </div>


// import Vue from 'vue/dist/vue.esm'
// import App from '../app.vue'
//
// document.addEventListener('DOMContentLoaded', () => {
//   const app = new Vue({
//     el: '#hello',
//     data: {
//       message: "Can you say hello?"
//     },
//     components: { App }
//   })
// })
//
//
//
// If the using turbolinks, install 'vue-turbolinks':
//
// yarn add 'vue-turbolinks'
//
// Then uncomment the code block below:
//
// import TurbolinksAdapter from 'vue-turbolinks'
// import Vue from 'vue/dist/vue.esm'
// import App from '../app.vue'
//
// Vue.use(TurbolinksAdapter)
//
// document.addEventListener('turbolinks:load', () => {
//   const app = new Vue({
//     el: '#hello',
//     data: {
//       message: "Can you say hello?"
//     },
//     components: { App }
//   })
// })
