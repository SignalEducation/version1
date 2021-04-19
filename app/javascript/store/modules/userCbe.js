/* eslint-disable no-param-reassign */
/* eslint no-shadow: ["error", { "allow": ["state"] }] */

const state = {
  user_cbe_data: {
    user_id: null,
    cbe_id: null,
    exercise_id: null,
    user_agreement: false,
    current_state: null,
    questions: {},
    responses: {},
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
    context.commit("setUserCbeData", newData);
  },
  recordUserLog(context, newData) {
    context.commit("setUserLog", newData);
  },
  recordAnswer(context, newData) {
    context.commit("setAnswerData", newData);
  },
  recordResponse(context, newData) {
    context.commit("setResponseData", newData);
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
      if (section.kind == 'exhibits_scenario') {
        section.scenarios.forEach((scenario) => {
          page += 1;
          examPages.push(examPageObject(`Case Study ${page}`, 'scenarios', scenario.id, page));
        });
      } else {
        section.questions.forEach((question) => {
          page += 1;
          examPages.push(examPageObject(`Question ${page}`, 'questions', question.id, page));
        });
      }
    });

    return examPages;
  },
};

const mutations = {
  setUserCbeData(state, newDat) {
    state.user_cbe_data.cbe_id = newDat.cbe_id;
    state.user_cbe_data.user_id = newDat.user_id;
    state.user_cbe_data.exercise_id = newDat.exercise_id;
    state.user_cbe_data.exam_pages = functions.reviewPageLinks(
      newDat.cbe_data.sections
    );
  },
  setUserLog(state, data) {
    state.user_cbe_data.status = data.status;
    state.user_cbe_data.user_log_id = data.id;
    state.user_cbe_data.user_agreement = data.agreed;
    state.user_cbe_data.current_state = data.current_state;

    data.user_questions.forEach(question => {
      state.user_cbe_data.questions[question.cbe_question_id] = question;
    });

    data.user_responses.forEach(response => {
      state.user_cbe_data.responses[response.cbe_response_option_id] = response;
    });
  },
  setAnswerData(state, question) {
    state.user_cbe_data.questions[question.id] = question;
  },
  setResponseData(state, response) {
    state.user_cbe_data.responses[response.id] = response;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
