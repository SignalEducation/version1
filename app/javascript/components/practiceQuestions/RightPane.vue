<template>
  <section>
    <div style="padding:15px;">
      <ul class="flex-container">
        <li v-if="totalQuestions > 1" @click="prevPage" class="lightgrey nav-ques-arrow"> &laquo; </li>
        <li v-else class="lightgrey nav-ques-arrow-shw"> &raquo; </li>
        <li class="flex-item">Question {{this.activePage}} of {{totalQuestions}}</li>
        <li v-if="this.activePage < totalQuestions && totalQuestions > 1" @click="nextPage(totalQuestions)" class="lightgrey nav-ques-arrow"> &raquo; </li>
        <li v-else class="lightgrey nav-ques-arrow-shw"> &raquo; </li>
      </ul>
      <p v-html="questionContentArray[this.activePage-1].content"></p>
    </div>
  </section>
</template>

<script>

import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus
  },
  props: {
  	totalQuestions: {
      type: Number,
    },
    questionContentArray: {
      type: Array,
    },
  },
  data() {
    return {
      modalIsOpen: false,
      activePage: 1,
      isActive: true,
    };
  },
  mounted() {
    this.questionArrIndexOf(this.questionContentArray);
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    questionArrIndexOf(questionContentArray) {
      questionContentArray.forEach(function (question, index) {
        console.log(question.content, index);
      });
    },
    changePage: function(num) {
      this.activePage = num
    },
    nextPage: function(lastQuestion) {
      if(this.activePage < lastQuestion) this.activePage++
    },
    prevPage: function() {
      if(this.activePage > 1) this.activePage--
    }
  },
  watch: {
    activePage: function(newVal, oldVal) {
      eventBus.$emit("active-solution-index", newVal-1);
    },
  },
};
</script>