/* eslint-disable no-param-reassign */
/* eslint no-shadow: ["error", { "allow": ["state"] }] */

import Vue from 'vue';
import Vuex from 'vuex';
import cbe from './modules/cbe';
import userCbe from './modules/userCbe';
import cbeDetails from './modules/cbeDetails';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    cbe,
    cbeDetails,
    userCbe,
  },
  state: {
    cbeDetailsSaved: false,
    cbeId: null,
    currentSectionId: null,
    currentQuestionId: null,
  },
  mutations: {
    hideDetailsForm(state, value) {
      state.cbeDetailsSaved = value;
    },
    setCbeId(state, value) {
      state.cbeId = value;
    },
  },
});
