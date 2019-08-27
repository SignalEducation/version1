/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'cbe_main' %> (and
// <%= stylesheet_pack_tag 'cbe_main' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue'
import Vuex from 'vuex'
import App from '../app'
import Show from 'Show'
import splitPane from 'vue-splitpane'
import VeeValidate from 'vee-validate';
import VueRouter from 'vue-router'
import BootstrapVue from 'bootstrap-vue'
import { connect } from 'tls';

Vue.use(Vuex)
Vue.component('split-pane', splitPane);
Vue.use(VeeValidate);
Vue.use(VueRouter);
Vue.use(BootstrapVue)

export const store = new Vuex.Store({
  state: {
    currentCbeId: 109,
    currentSectionId: null,
    currentSubjectCourseId: null,
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
    showQuestions: false,
    showSections: false,
    showCBEDetails: false,
    selectedQuestionType: null,
    multipleChoiceSelected: false,
    currentMultilpleQuestionId: null,
    cbeQuestions: ['{"id": 5, "cbe_section_id": 5,"questionDescription": "How much does an Accountant Earn?","type": "Multiple Choice","correctAnswer": true}'],
  },

  getters: {
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
    showQuestions: (state, getters) => {
      return getters.showQuestions
    },
    showSections: (state, getters) => {
      return getters.showSections
    },
    currentQuestionType: (state, getters) => {
      return getters.currentQuestionType
    },
    multipleChoiceSelected: (state, getters) => {
      return getters.multipleChoiceSelected
    },
    currentMultilpleQuestionId: (state, getters) => {
      return getters.currentMultilpleQuestionId
    },
    currentSubjectCourseId: (state, getters) => {
      return getters.currentSubjectCourseId
    },
    showCBEDetails: (state, getters) => {
      return getters.showCBEDetails
    },
    cbeQuestions: (state, getters) => {
      return $store.state.cbeQuestions
    },
    questionById: (state) => (id) => {
     console.log("** Question by id " + id)
      return state.cbeQuestions.find(question => question.id === id)
    }

  },

  mutations: {
    setCurrentCbeId(state, value) {
      state.currentCbeId = value
    },
    setCurrentSectionId(state, value) {
      state.currentSectionId = value
    },
    setCbeName(state, value) {
      state.cbeName = value
    },
    setCbeSectionName(state, value) {
      state.cbeSectionName = value
    },
    setCbeTitle(state, value) {
      state.cbeTitle = value
    },
    setCbeDescription(state, value) {
      state.cbeDescription = value
    },
    setCbeTimeLimit(state, value) {
      state.cbeTimeLimit = value
    },
    setCbeNumberOfPauses(state, value) {
      state.cbeNumberOfPauses = value
    },
    setCbeLengthOfPauses(state, value) {
      state.cbeLengthOfPauses = value
    },
    setQuestionTypes(state, value) {
      state.questionTypes = value
    },
    setQuestionStatuses(state, value) {
      state.questionStatuses = value
    },
    setSectionTypes(state, value) {
      state.sectionTypes = value
    },
    setShowQuestions: (state, value) => {
      state.showQuestions = value
    },
    setCurrentQuestionType: (state, value) => {
      state.currentQuestionType = value
    },
    setMultipleChoiceSelected: (state, value) => {
      state.multipleChoiceSelected = value
    },
    currentMultilpleQuestionId: (state, value) => {
      state.currentMultilpleQuestionId = value

    },
    currentSubjectCourseId: (state, value) => {
      state.currentSubjectCourseId = value
    },
    addCbeQuestion: (state, value) => {
      state.cbeQuestions.push({value})
    },
  },

  /*
  computed:{
    cbeQuestions(){
      return this.$store.state.cbeQuestions;
    },
  },

  */
})

document.addEventListener('DOMContentLoaded', () => {
  const el = document.body.appendChild(document.createElement('vueapp'))
  const vue = new Vue({
    store: store,
    el: '#cbes-new-view',
    template: '<App/>',
    components: { App },
    render: h => h(App)
  })
})

document.addEventListener('DOMContentLoaded', () => {
  const el = document.body.appendChild(document.createElement('vueapp'))
  const vue = new Vue({
    store: store,
    el: '#cbes-show-view',
    template: '<Show/>',
    components: { Show },
    render: h => h(Show)
  })

})
