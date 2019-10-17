/* eslint-disable no-param-reassign */
/* eslint no-shadow: ["error", { "allow": ["state"] }] */

const state = {
  user_cbe_data: {
    user_id: null,
    cbe_id: null,
    questions: {},
    exam_pages: {
      state: null,
      flagged: false,
      description: null,
      type: null,
      param: null,
    },
  },
};

const getters = {
  userCbeData: state => state.user_cbe_data,
};

const actions = {
  startUserCbeData(context, newData) {
    context.commit('setUserCbeData', newData);
  },
  recordAnswer(context, newData) {
    context.commit('setAnswerData', newData);
  },
};

const examPageObject = (description, type, id) => ({
  description,
  state: 'Unseen',
  flagged: false,
  type,
  param: id,
});

const functions = {
  reviewPageLinks(sections) {
    const examPages = [];

    sections.forEach((section) => {
      examPages.push(examPageObject(section.name, 'sections', section.id));
      section.questions.forEach((question) => {
        examPages.push(examPageObject(question.kind, 'questions', question.id));
      });
    });

    return examPages;
  },
};

const mutations = {
  setUserCbeData(state, newDat) {
    state.user_cbe_data.cbe_id = newDat.cbe_id;
    state.user_cbe_data.user_id = newDat.user_id;
    state.user_cbe_data.exam_pages = functions.reviewPageLinks(newDat.cbe_data.sections);
  },
  setAnswerData(state, question) {
    state.user_cbe_data.questions[question.id] = question;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
