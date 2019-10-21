/* eslint-disable no-param-reassign */
/* eslint no-shadow: ["error", { "allow": ["state"] }] */

const state = {
  cbe_data: {},
  edit_cbe_data: {},
};

const getters = {
  cbe_data: state => state.cbe_data,
  edit_cbe_data: state => state.edit_cbe_data,
};

const actions = {
  getCbe(context, cbeId) {
    fetch(`/api/v1/cbes/${cbeId}`)
      .then(response => response.json())
      .then((response) => {
        context.commit('setCbeData', response);
      });
  },
  getEditCbe(context, cbeId) {
    fetch(`/api/v1/cbes/${cbeId}/edit`)
      .then(response => response.json())
      .then((response) => {
        context.commit('setEditCbeData', response);
      });
  },
};

const mutations = {
  setCbeData(state, newData) {
    state.cbe_data = newData;
  },
  setEditCbeData(state, newData) {
    state.edit_cbe_data = newData;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
