const state = {
  cbe_data: {}
}

const getters = {
  cbeData: (state) => {
    return state.cbe_data
  }
}

const actions = {
  getCbe(context, cbe_id) {
    fetch(`/api/v1/cbes/${cbe_id}`)
      .then(response => response.json())
      .then(response => {
        context.commit('setCbeData', response);
      });
  }
}

const mutations = {
  setCbeData(state, data) {
    state.cbe_data = data
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
