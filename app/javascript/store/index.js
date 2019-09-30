import Vue        from 'vue'
import Vuex       from 'vuex'
import cbe        from './modules/cbe'
import userCbe    from './modules/user_cbe'
import cbeDetails from './modules/cbe_details'

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    cbe,
    cbeDetails,
    userCbe
  },

  state: { // data
    cbeDetailsSaved: false,
    cbeId: null,
    currentSectionId: null,
    currentQuestionId: null,
  },

  mutations: {
    hideDetailsForm(state, value) {
      state.cbeDetailsSaved = value
    },
    setCbeId(state, value) {
      state.cbeId = value
    }
  }
});
