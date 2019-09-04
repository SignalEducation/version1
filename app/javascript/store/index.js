import Vuex from 'vuex'
import Vue from 'vue'
import cbeDetails from './modules/cbe_details'

Vue.use(Vuex);

export default new Vuex.Store({

    modules: {
        cbeDetails
    },

    state: { // data
        cbeDetailsSaved: false,
        cbeId: null,
        currentSectionId: null,
        currentQuestionId: null,
    },

    getters: { // computed properties

    },

    actions: {

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
