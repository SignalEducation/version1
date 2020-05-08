/* eslint-disable no-param-reassign */
/* eslint no-shadow: ["error", { "allow": ["state"] }] */

export default {
  state: {
    cbeName: null,
    cbeAgreementContent: null,
    cbeCourseId: null,
    cbeActive: null,
    currentCbe: '',
  },

  getters: {
    currentCbe: state => state.currentCbe,
  },

  mutations: {
    setCbeName(state, value) {
      state.cbeName = value;
    },
    setCbeAgreementContent(state, value) {
      state.cbeAgreementContent = value;
    },
    setCbeExamTime(state, value) {
      state.cbeExamTime = value;
    },
    setCbeCourseId(state, value) {
      state.cbeCourseId = value;
    },
    setCbeActive(state, value) {
      state.cbeActive = value;
    },
    setCurrentCbe(state, value) {
      state.currentCbe = value;
    },
  },
};
