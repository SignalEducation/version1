<template>
  <section>
    <div
      v-if="questionData.id == id"
      :key="id"
      class="questions"
    >
      <splitpanes
        class="default-theme"
        :style="{ height: height + 'px' }"
      >
        <span
          v-if="questionData.scenario != null"
          v-html="questionData.scenario.content"
        />
        <span>
          <section class="cbe-content-template" v-html="questionData.content" />

          <QuestionAnswers
            :answers-data="questionData.answers"
            :question-id="questionData.id"
            :question-kind="questionData.kind"
            :question-score="questionData.score"
          />
        </span>
      </splitpanes>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex';
import Splitpanes from 'splitpanes';
import QuestionAnswers from '../../components/cbe/QuestionAnswers.vue';

export default {
  components: {
    Splitpanes,
    QuestionAnswers,
  },
  props: {
    id: {
      type: [Number, String],
      required: true
    }
  },
  data() {
    return {
      height: 200,
    };
  },
  computed: {
    ...mapGetters('cbe', {
      cbeData: 'cbe_data',
    }),
    questionData() {
      let cbeQuestion = {};
      const questionId = parseInt(this.id);

      if(this.cbeData !== null && questionId!== null) {
        cbeQuestion = this.cbeData.questions.find(function(element) {
          return element.id === questionId;
        });

      }
      return cbeQuestion;
    },
  },
  mounted() {
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  },
  methods: {
    handleResize() {
      const headerFooter =
        $('#cbe-nav-header').height() +
        $('#cbe-footer')
          .children()
          .first()
          .height();
      this.height = $(window).height() - headerFooter;
    },
  },
};
</script>
