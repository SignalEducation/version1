<template>
  <section>
    <div
      class="questions"
      v-for="question in cbe_data.questions"
      v-if="question.id == id"
      :key="question.id"
    >
      <splitpanes class="default-theme" v-bind:style="{ height: height + 'px'}">
        <span v-if="question.scenario != null" v-html="question.scenario.content"></span>
        <span>
          <section v-html="question.content" />

          <QuestionAnswers
            :answers="question.answers"
            :question_id="question.id"
            :question_kind="question.kind"
          />
        </span>
      </splitpanes>
    </div>
  </section>
</template>

<script>
import { mapGetters } from "vuex";
import Splitpanes from "splitpanes";
import QuestionAnswers from "../../components/cbe/QuestionAnswers";

export default {
  components: {
    Splitpanes,
    QuestionAnswers
  },
  data() {
    return {
      height: 200
    };
  },
  mounted() {
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
  },
  props: {
    id: Number
  },
  computed: {
    ...mapGetters("cbe", {
      cbe_data: 'cbe_data',
    }),
  },
  methods: {
    handleResize: function() {
      let headerFooter = $("#cbe-nav-header").height() + $("#cbe-footer").children().first().height();
      this.height = $(window).height() - headerFooter;
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  }
};
</script>

