<template>
  <section>
    <div style="display:flex;flex-direction:row;margin-bottom:-11px;">
      <ModalCalculator />
      <ModalScratchPad />
      <ModalSolution :solutionTitle="practiceQuestion.course_step.name" :solutionDescription="practiceQuestion.answers[0].solution" />
    </div>
    <div
      class="questions"
    >
      <splitpanes
        class="practice-question-theme"
        :style="{ height: '70vh' }"
      >
        <span>
          <LeftPane :content="practiceQuestion.content" />
        </span>
      <span>
        <RightPane :totalQuestions="practiceQuestion.course_step.number_of_questions" />
      </span>
      </splitpanes>
          <HelpBtn />
          <SubmitBtn />
    </div>
  </section>
</template>

<script>
import axios from 'axios';
import { mapGetters } from 'vuex';
import SubmitBtn from '../../components/practiceQuestions/SubmitBtn.vue';
import HelpBtn from '../../components/practiceQuestions/HelpBtn.vue';
import Splitpanes from 'splitpanes';
import LeftPane from './LeftPane.vue';
import RightPane from './RightPane.vue';
import ModalCalculator from './ModalCalculator.vue';
import ModalScratchPad from './ModalScratchPad.vue';
import ModalSolution from './ModalSolution.vue';
import QuestionAnswers from '../../components/cbe/QuestionAnswers.vue';


export default {
  components: {
    SubmitBtn,
    HelpBtn,
    Splitpanes,
    LeftPane,
    RightPane,
    ModalCalculator,
    ModalScratchPad,
    ModalSolution,
    QuestionAnswers,
  },
  data() {
    return {
      practiceQuestionId: this.$parent.practiceQuestionId,
      practiceQuestion: null,
    };
  },
  mounted() {
    this.getPracticeQuestion();
  },
  methods: {
    getPracticeQuestion() {
      axios
        .get(`/api/v1/practice_questions/${this.practiceQuestionId}`)
        .then(response => {
          this.practiceQuestion = response.data;
        })
        .catch(e => {});
    },
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
