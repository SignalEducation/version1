<template>
  <section v-if="!isFetching">
    <div class="top-btns-prac-ques">
      <div class="top-btns-left-pane">
        <ModalCalculator class="top-btns-left-pane-spc" />
        <ModalScratchPad />
      </div>
      <div class="top-btns-left-pane">
        <CloseAllModals v-if="practiceQuestion.kind != 'standard'" class="top-btns-left-pane-spc" />
        <span v-if="practiceQuestion.kind == 'standard'">
          <ModalSolution :solutionTitle="practiceQuestion.course_step.name" :solutionContent="practiceQuestion.questions" />
        </span>
        <span v-else>
          <ModalSolutionV2 :solutionContentArray="practiceQuestion.solutions_v2" />
        </span>
      </div>
    </div>
    <div class="questions">
      <splitpanes class="practice-question-theme" :style="{ height: '70vh' }">
        <span v-if="practiceQuestion.kind == 'standard'">
          <ScenarioPane :content="practiceQuestion.content" />
        </span>
        <span v-else>
          <ExhibitsRequirementsPane
            :totalQuestions="practiceQuestion.total_questions"
            :requirementContentArray="practiceQuestion.questions"
            :stepLogId="stepLogId"
            :practiceQuestionId="practiceQuestionId"
            :exhibitContentArray="practiceQuestion.exhibits"
            :responseContentArray="practiceQuestion.responses" />
        </span>
        <span v-if="practiceQuestion.kind == 'standard'">
          <QuestionsAnswersPane
            :totalQuestions="practiceQuestion.total_questions"
            :questionContentArray="practiceQuestion.questions"
            :stepLogId="stepLogId"
            :practiceQuestionId="practiceQuestionId"
          />
        </span>
        <span v-else>
          <ScenarioPane :content="practiceQuestion.content" />
        </span>
      </splitpanes>
        <HelpBtn :helpPdf="practiceQuestion.document.url" />
      <div v-if="practiceQuestion.kind == 'standard'" :title="dynamicTitle" :class="{ outsidelastpage: outsideLastPage }">
        <SubmitBtn
          :totalQuestions="practiceQuestion.total_questions"
          :questionContentArray="practiceQuestion.questions"
          :stepLogId="stepLogId"
          :practiceQuestionId="practiceQuestionId"
        />
      </div>
      <div v-else :title="dynamicTitle" :class="{ outsidelastpage: outsideLastPage }">
        <SubmitBtnV2
          :sendResponseArraytoDB="practiceQuestion.responses"
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
import SubmitBtnV2 from "../../components/practiceQuestions/SubmitBtnV2.vue";
import HelpBtn from "../../components/practiceQuestions/HelpBtn.vue";
import Splitpanes from "splitpanes";
import ScenarioPane from "./ScenarioPane.vue";
import QuestionsAnswersPane from "./QuestionsAnswersPane.vue";
import ExhibitsRequirementsPane from "./ExhibitsRequirementsPane.vue";
import ModalCalculator from "./ModalCalculator.vue";
import ModalScratchPad from "./ModalScratchPad.vue";
import ModalSolution from "./ModalSolution.vue";
import ModalSolutionV2 from "./ModalSolutionV2.vue";
import CloseAllModals from "./CloseAllModals.vue";
import QuestionAnswers from "../../components/cbe/QuestionAnswers.vue";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    SubmitBtn,
    SubmitBtnV2,
    HelpBtn,
    Splitpanes,
    ScenarioPane,
    QuestionsAnswersPane,
    ExhibitsRequirementsPane,
    ModalCalculator,
    ModalScratchPad,
    ModalSolution,
    ModalSolutionV2,
    CloseAllModals,
    QuestionAnswers,
    eventBus,
  },
  data() {
    return {
      stepLogId: this.$parent.stepLogId,
      practiceQuestionId: this.$parent.practiceQuestionId,
      practiceQuestion: null,
      zIndexArr: ["calcModal", "scratchPadModal", "solutionModal", "helpModal", "solutionModalV2", "textEditorModal", "spreadsheetModal"],
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
    eventBus.$on("active-solution-index-v2",(showSubmitBtn)=>{
      if (showSubmitBtn) {
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
          this.zIndexLoadArr(this.practiceQuestion.exhibits,this.practiceQuestion.questions,this.practiceQuestion.responses);
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
      for (let index = 0; index < modalArr.length; index++) {
        try {
          document.getElementById(modalArr[index]).style.zIndex = 1099-index;
        } catch(e) {}
      }
    },
    zIndexLoadArr(exh, ques, resp) {
      console.log(exh);
      for (let index = 0; index < exh.length; index++) {
        this.zIndexArr.push(`exhibitsModal${index}`);
      }
      for (let index = 0; index < ques.length; index++) {
        this.zIndexArr.push(`requirementsModal${index}`);
      }
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
