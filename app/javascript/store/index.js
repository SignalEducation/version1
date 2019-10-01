/* eslint-disable */

import Vue from 'vue';
import Vuex from 'vuex';
import cbe from './modules/cbe';
import user_cbe from './modules/user_cbe';
import cbe_details from './modules/cbe_details';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    cbe,
    cbe_details,
    user_cbe,
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
