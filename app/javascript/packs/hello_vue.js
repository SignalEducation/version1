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
        currentCbeId: null,
        currentSectionId: null,
        currentSubjectId: null,
        cbeName: null,
        cbeSectionName: null,
        cbeTitle: null,
        cbeDescription: null,
        cbeTimeLimit: null,
        cbeNumberOfAllowablePauses: null,
        cbeNumberOfPauses: null,
        cbeLengthOfPauses: null,
        cbeQuestionTypes: [],
        cbeQuestionStatuses: [],
        cbeSectionTypes: [],
        cbeQuestionTypes: [],
        cbeQuestionStatuses: []
    },

    getters: {
        // ...
        currentCbeId: (state, getters) => {
          return getters.currentCbeId
        },
        questionTypes: (state, getters) => {
            return getters.questionTypes
        },
        questionStatuses: (state, getters) => {
            return getters.questionStatuses
        },
        sectionTypes: (state, getters) => {
            return getters.sectionTypes
        },
        currentSectionId: (state, getters) => {
            return getters.currentSectionId
        },
      },

    mutations: {
        setCurrentCbeId(state, value) {
            state.currentCbeId  = value
        },
        setCurrentSectionId(state, value) {
            state.currentSectionId  = value
        },
        setCbeName(state, value) {
            state.cbeName  = value
        },
        setCbeSectionName(state, value) {
            state.cbeSectionName  = value
        },
        setCbeTitle(state, value) {
            state.cbeTitle  = value
        },
        setCbeDescription(state, value) {
            state.cbeDescription  = value
        },
        setCbeTimeLimit(state, value) {
            state.cbeTimeLimit  = value
        },
        setCbeNumberOfPauses(state, value) {
            state.cbeNumberOfPauses  = value
        },
        setCbeLengthOfPauses(state, value) {
            state.cbeLengthOfPauses  = value
        },
        setQuestionTypes(state, value) {
            state.questionTypes  = value
        },
        setQuestionStatuses(state, value) {
            state.questionStatuses  = value
        },
        setSectionTypes(state, value) {
            state.sectionTypes  = value
        },
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
