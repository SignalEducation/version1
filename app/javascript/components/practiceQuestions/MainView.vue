<template>
  <section v-if="!isFetching">
    <div class="top-btns-prac-ques">
      <div class="top-btns-left-pane">
        <ModalCalculator class="top-btns-left-pane-spc"/>
        <ModalScratchPad />
      </div>
      <ModalSolution :solutionTitle="practiceQuestion.course_step.name" :solutionContent="practiceQuestion.questions"  />
    </div>
    <div class="questions">
      <splitpanes class="practice-question-theme" :style="{ height: '70vh' }">
        <span>
          <LeftPane :content="practiceQuestion.content" />
        </span>
        <span>
          <RightPane
            :totalQuestions="practiceQuestion.total_questions"
            :questionContentArray="practiceQuestion.questions"
            :stepLogId="stepLogId"
            :practiceQuestionId="practiceQuestionId"
          />
        </span>
      </splitpanes>
      <HelpBtn :helpPdf="practiceQuestion.document.url" />
      <div :title="dynamicTitle" :class="{ outsidelastpage: outsideLastPage }">
        <SubmitBtn
          :totalQuestions="practiceQuestion.total_questions"
          :questionContentArray="practiceQuestion.questions"
          :stepLogId="stepLogId"
          :practiceQuestionId="practiceQuestionId"
        />
      </div>
    </div>
  </section>
</template>

<script>
import axios from "axios";
import { mapGetters } from "vuex";
import SubmitBtn from "../../components/practiceQuestions/SubmitBtn.vue";
import HelpBtn from "../../components/practiceQuestions/HelpBtn.vue";
import Splitpanes from "splitpanes";
import LeftPane from "./LeftPane.vue";
import RightPane from "./RightPane.vue";
import ModalCalculator from "./ModalCalculator.vue";
import ModalScratchPad from "./ModalScratchPad.vue";
import ModalSolution from "./ModalSolution.vue";
import QuestionAnswers from "../../components/cbe/QuestionAnswers.vue";
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
      zIndexArr: ["calcModal", "scratchPadModal", "solutionModal", "helpModal"],
      outsideLastPage: true,
      dynamicTitle: "All answers required before completing",
      lastPageIndex: null,
      isFetching: true,
      latestAnswer: false,
      updateAnsArr: null,
    };
  },
  created() {
    this.loadingPracticeQuestion();
    eventBus.$on("z-index-click", (lastClickedModal) => {
      this.zIndexSort(lastClickedModal);
      this.zIndexStyle(this.zIndexArr);
    }),
    eventBus.$on("update-answer-text",(ans)=>{
      if (ans.length > 0) {
        this.latestAnswer = true;
        this.evaluateAnsText(true);
      } else {
        this.evaluateAnsText(false);
      }
    }),
    eventBus.$on("active-solution-index",(showSubmitBtn)=>{
      if (showSubmitBtn[0]) {
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
        .get(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`
        )
        .then((response) => {
          this.practiceQuestion = response.data;
          this.isFetching = false;
          this.loader.hide();
          let fillArr = new Array(this.practiceQuestion.total_questions);
          this.updateAnsArr = fillArr.fill(0);
        })
        .catch((e) => {});
    },
    handleResize() {
      const headerFooter =
        $("#cbe-nav-header").height() +
        $("#cbe-footer")
          .children()
          .first()
          .height();
      this.height = $(window).height() - headerFooter;
    },
    zIndexSort(lastModal) {
      let index = this.zIndexArr.indexOf(lastModal);
      if (index > 0) {
        this.zIndexArr.splice(index, 1);
        this.zIndexArr.unshift(lastModal);
      }
    },
    zIndexStyle(modalArr) {
      document.getElementById(modalArr[0]).style.zIndex = 1033;
      document.getElementById(modalArr[1]).style.zIndex = 1032;
      document.getElementById(modalArr[2]).style.zIndex = 1031;
      document.getElementById(modalArr[3]).style.zIndex = 1030;
    },
    evaluateAnsText(latestAns) {
      if (this.practiceQuestion.total_questions == 1 && latestAns) {
        this.outsideLastPage = false;
        this.dynamicTitle = 'Mark as Complete';
      } else {
        this.outsideLastPage = true;
        this.dynamicTitle = 'All answers required before completing';
      }
    },
    loadingPracticeQuestion() {
      this.loader = this.$loading.show({
        loader: "dots",
        color: "#00b67B",
        opacity: 0.98,
        container: this.fullPage ? null : this.$refs.formContainer,
      });
    },
  },
};
</script>
