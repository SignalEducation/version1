const state = {
  user_cbe_data: {
    user_id: null,
    cbe_id: null,
    questions: {},
    exam_pages: {
      state: null,
      flagged: false,
      description: null
    }
  }
};

const getters = {
  userCbeData: (state) => {
    return state.user_cbe_data
  }
};

const actions = {
  startUserCbeData(context, data) {
    context.commit('setUserCbeData', data);
  },
  recordAnswer(context, data) {
    context.commit('setAnswerData', data);
  }
};

const mutations = {
  setUserCbeData(state, data) {
    state.user_cbe_data.cbe_id = data.cbe_id;
    state.user_cbe_data.user_id = data.user_id;
    state.user_cbe_data.exam_pages = functions.reviewPageLinks(data.cbe_data.sections)
  },
  setAnswerData(state, question) {
    state.user_cbe_data.questions[question.id] = question;
  },
};

const functions = {
  reviewPageLinks(sections) {
    var exam_pages = [];

    sections.filter(section => {
      exam_pages.push({ description: section.name, state: 'Unseen', flagged: false })
      section.questions.filter(question => {
        exam_pages.push({ description: question.sorting_order, state: 'Unseen', flagged: false })
      });
    });

    return exam_pages;
  }
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
