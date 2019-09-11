<template>
  <div>
    <h1> Edit CBE Details</h1>

    <div class="row ">
      <div class="col-sm-6">
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
      </div>


    </div> <!-- row -->

    <div class="row ">
      <div class="col-sm-6">
        <label for="cbe-title">Title</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('cbe-title')"
            @click="focusField('cbe-title')"
          >{{cbe.title}}</span>
          <input
            v-model="cbe.title"
            v-show="showField('cbe-title')"
            id="cbe-title"
            type="text"
            class="field-value form-control"
            @focus="focusField('cbe-title')"
            @blur="blurField"
          />
        </div>
      </div>

      <div class="col-sm-6">
        <label for="content">Content</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('content')"
            @click="focusField('content')"
          >{{cbe.content}}</span>
          <input
            v-model="cbe.content"
            v-show="showField('content')"
            type="content"
            class="field-value form-control"
            @focus="focusField('content')"
            @blur="blurField"
          />
        </div>
      </div>
    </div> <!-- row -->

    <div class="row ">
      <div class="col-sm-6">
        <label for="agreement_content">Agreement Content</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('agreement_content')"
            @click="focusField('agreement_content')"
          >{{cbe.agreement_content}}</span>
          <input
            v-model="cbe.agreement_content"
            v-show="showField('agreement_content')"
            id="agreement_content"
            type="text"
            class="field-value form-control"
            @focus="focusField('agreement_content')"
            @blur="blurField"
          />
        </div>
      </div>

      <div class="col-sm-6">
        <label for="exam_time">Exam Time</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('exam_time')"
            @click="focusField('exam_time')"
          >{{cbe.exam_time}}</span>
          <input
            v-model="cbe.exam_time"
            v-show="showField('exam_time')"
            type="exam_time"
            class="field-value form-control"
            @focus="focusField('exam_time')"
            @blur="blurField"
          />
        </div>
      </div>
    </div> <!-- row -->

  </div>
</template>

<script>
import axios from 'axios';

export default {
  mounted() {
    this.getCBEId();
    this.fetchCbe();
  },
  data() {
    return {
      cbe: {},
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
