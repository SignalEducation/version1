/* eslint-disable */

export default {
  state: {
    cbeName: null,
    cbeAgreementContent: null,
    cbeSubjectCourseId: null,
    cbeActive: null,
    currentCbe: '',
  },

  getters: {
    currentCbe: (state) => state.currentCbe,
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
    setCbeSubjectCourseId(state, value) {
      state.cbeSubjectCourseId = value;
    },
    setCbeActive(state, value) {
      state.cbeActive = value;
    },
    setCurrentCbe(state, value) {
      state.currentCbe = value;
    },
  },
};
