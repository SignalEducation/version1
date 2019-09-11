<template>
  <div>
    <h1>CBE settings</h1>
    <label for="cbe-name">CBE</label>
    <div class="field">
      <span
        class="field-value"
        v-show="!showField('name')"
        @click="focusField('name')"
      >{{cbe.name}}</span>
      <input
        v-model="cbe.name"
        v-show="showField('name')"
        id="cbe-name"
        type="text"
        class="field-value form-control"
        @focus="focusField('name')"
        @blur="blurField"
      />
    </div>

    <label for="cbe-id">CBE Section</label>
    <div class="field">
      <span
        class="field-value"
        v-show="!showField('id')"
        @click="focusField('id')"
      >{{cbe.id}}</span>
      <input
        v-model="cbe.id"
        v-show="showField('id')"
        type="id"
        class="field-value form-control"
        @focus="focusField('id')"
        @blur="blurField"
      />

      <span></span>
      <div class="row">
        <div class="col-sm-10">
          <div class="form-group">
            <select
              v-model="selectedCbe"
              class="form-control custom-select"
            >
              <option
                class="col-md-8"
                v-for="option in options"
                v-bind:value="option.id"
                v-bind:key="option.id"
              >
                {{option.name}}
              </option>
            </select>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  mounted() {
    console.log('IN Mount');
    this.getCBEId();
    this.fetchCbe();
  },
  data() {
    return {
      cbe: {
        name: 'CBE 1',
        id: '1',
      },
      editField: '',
      options: [],
      selectedCbe: '',
      cbe_id: null,
    };
  },
  methods: {
    focusField(name) {
      this.editField = name;
    },
    blurField() {
      this.editField = '';
    },
    showField(name) {
      return this.cbe[name] === '' || this.editField === name;
    },
    // fetches all cbes
    // eslint-disable-next-line no-unused-vars
    fetchAllCbes(page, index) {
      axios
        .get('http://localhost:3000/api/v1/cbes/')
        .then((response) => {
          // this.$store.questionTypes = response.data
          this.options = response.data;
        })
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.log(`Error${e}`);
        });
    },
    getCBEId() {
      const url = document.URL;
      this.cbe_id = url.substr(url.lastIndexOf('/') + 1);
    },
    // eslint-disable-next-line no-unused-vars
    fetchCbe(page, index) {
      axios
        .get(`http://localhost:3000/api/v1/cbes/${this.cbe_id}`)
        .then((response) => {
          this.cbe = response.data;
          this.$store.commit('setCurrentCbe', this.cbe);
          console.log(this.cbe);
          console.log('------');
          console.log(this.$store.state.cbeDetails.currentCbe);
        })
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.log(`Error${e}`);
        });
    },
  },
};
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
