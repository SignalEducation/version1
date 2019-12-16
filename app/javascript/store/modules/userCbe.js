/* eslint-disable no-param-reassign */
/* eslint no-shadow: ["error", { "allow": ["state"] }] */

const state = {
  user_cbe_data: {
    user_id: null,
    cbe_id: null,
    exercise_id: null,
    questions: {},
    status: "",
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
  recordUserLog(context, newData) {
    context.commit('setUserLog', newData);
  },
  recordAnswer(context, newData) {
    context.commit('setAnswerData', newData);
  },
};

const examPageObject = (description, type, param, page, state = 'Unseen') => ({
  description,
  state,
  flagged: false,
  type,
  param,
  page
});

const functions = {
  reviewPageLinks(sections) {
    const examPages = [];
    let page = 0;

    sections.forEach((section) => {
      examPages.push(examPageObject(section.name, 'sections', section.id, null));
      section.questions.forEach((question) => {
        page += 1;
        examPages.push(examPageObject(`Question ${page}`, 'questions', question.id, page));
      });
    });

    return examPages;
  },
};

const mutations = {
  setUserCbeData(state, newDat) {
    state.user_cbe_data.cbe_id = newDat.cbe_id;
    state.user_cbe_data.user_id = newDat.user_id;
    state.user_cbe_data.exercise_id = newDat.exercise_id;
    state.user_cbe_data.exam_pages = functions.reviewPageLinks(newDat.cbe_data.sections);
  },
  setUserLog(state, data) {
    state.user_cbe_data.status = data.status;
    state.user_cbe_data.user_log_id = data.id;
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
