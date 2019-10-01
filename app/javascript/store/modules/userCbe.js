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
  userCbeData: (state) => state.user_cbe_data,
};

const actions = {
  startUserCbeData(context, newData) {
    context.commit('setUserCbeData', newData);
  },
  recordAnswer(context, newData) {
    context.commit('setAnswerData', newData);
  },
};

const functions = {
  reviewPageLinks(sections) {
    const examPages = [];

    sections.forEach((section) => {
      examPages.push({
        description: section.name,
        state: 'Unseen',
        flagged: false,
        type: 'sections',
        param: section.id,
      });
      section.questions.forEach((question) => {
        examPages.push({
          description: question.kind,
          state: 'Unseen',
          flagged: false,
          type: 'questions',
          param: question.id,
        });
      });
    });

    return examPages;
  },
};

const mutations = {
  setUserCbeData(state, newDat) {
    state.user_cbe_data = newDat.cbe_id;
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
