/* eslint-disable */

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
      page: null,
      param: null
    },
    scratch_pad: null
  }
};

const getters = {
  user_cbe_data: state => state.user_cbe_data
};

const actions = {
  startUserCbeData(context, data) {
    context.commit("setUserCbeData", data);
  },
  recordAnswer(context, data) {
    context.commit("setAnswerData", data);
  }
};

const mutations = {
  setUserCbeData(state, data) {
    state.user_cbe_data.cbe_id = data.cbe_id;
    state.user_cbe_data.user_id = data.user_id;
    state.user_cbe_data.exam_pages = functions.reviewPageLinks(
      data.cbe_data.sections
    );
  },
  setAnswerData(state, question) {
    state.user_cbe_data.questions[question.id] = question;
  }
};

const functions = {
  reviewPageLinks(sections) {
    let exam_pages = [];
    let page = 0;

    sections.filter(section => {
      exam_pages.push({
        flagged: false,
        description: section.name,
        type: "sections",
        param: section.id
      });

      section.questions.filter(question => {
        page += 1;
        exam_pages.push(this.exam_pagesData(question, "questions", page));
      });
    });

    return exam_pages;
  },

  exam_pagesData(data, type, index) {
    return {
      state: "Unseen",
      flagged: false,
      description: `Question ${index}`,
      type: type,
      page: index,
      param: data.id
    };
  }
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};
