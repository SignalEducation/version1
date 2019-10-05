const state = {
  cbe_data: {},
  edit_cbe_data: {}
}

const getters = {
  cbeData: (state) => {
    return state.cbe_data
  },
  editCbeData: (state) => {
    return state.edit_cbe_data
  }
}

const actions = {
  getCbe(context, cbe_id) {
    fetch(`/api/v1/cbes/${cbe_id}`)
      .then(response => response.json())
      .then(response => {
        context.commit('setCbeData', response);
      });
  },
  getEditCbe(context, cbe_id) {
    fetch(`/api/v1/cbes/${cbe_id}/edit`)
      .then(response => response.json())
      .then(response => {
        context.commit('setEditCbeData', response);
      });
  },
}

const mutations = {
  setCbeData(state, data) {
    state.cbe_data = data
  },
  setEditCbeData(state, data) {
    state.edit_cbe_data = data
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
