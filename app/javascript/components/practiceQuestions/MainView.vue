<template>
  <section>
    <div class="top-btns-prac-ques">
      <ModalCalculator />
      <ModalScratchPad />
      <ModalSolution :solutionTitle="practiceQuestion.course_step.name" :solutionContent="practiceQuestion.questions"  />
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
        <RightPane :totalQuestions="practiceQuestion.total_questions" :questionContentArray="practiceQuestion.questions" :answerContentArray="practiceQuestion.questions" :stepLogId="stepLogId" />
      </span>
      </splitpanes>
          <HelpBtn />
          <div :title="dynamicTitle" :class="{ outsidelastpage: outsideLastPage }">
            <SubmitBtn />
          </div>
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
import eventBus from "../cbe/EventBus.vue";

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
    eventBus,
  },
  data() {
    return {
      stepLogId: this.$parent.stepLogId,
      practiceQuestionId: this.$parent.practiceQuestionId,
      practiceQuestion: null,
      zIndexArr: ['calcModal', 'scratchPadModal', 'solutionModal', 'helpModal'],
      outsideLastPage: true,
      dynamicTitle: 'All answers required before completing',
      lastPageIndex: null,
    };
  },
  created() {
    eventBus.$on("z-index-click",(lastClickedModal)=>{
      this.zIndexSort(lastClickedModal);
      this.zIndexStyle(this.zIndexArr);
    }),
    eventBus.$on("active-solution-index",(activePage)=>{
      if (activePage + 1 == this.practiceQuestion.total_questions) {
        this.outsideLastPage = false;
        this.dynamicTitle = 'Mark as Complete';
      } else {
        this.outsideLastPage = true;
        this.dynamicTitle = 'All answers required before completing';
      }
    })
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
    zIndexSort(lastModal) {
      let index = this.zIndexArr.indexOf(lastModal);
      if (index > 0) {
        this.zIndexArr.splice(index,1);
        this.zIndexArr.unshift(lastModal);
      }
    },
    zIndexStyle(modalArr) {
      document.getElementById(modalArr[0]).style.zIndex = 1033;
      document.getElementById(modalArr[1]).style.zIndex = 1032;
      document.getElementById(modalArr[2]).style.zIndex = 1031;
      document.getElementById(modalArr[3]).style.zIndex = 1030;
    },
  },
};
</script>
