<template>
  <section v-if="!isFetching" class="cr-practice-questions">
    <div class="scenario-box-nav scenario-box-nav-header">
      <div class="cr-navigation">
        <div class="cr-navigation-center cr-second-nav">
          <ul>
            <li>
              <div>
                <span>
                  <PreviousAttempts
                    :stepLogId="stepLogId"
                    :previousAttempts="previousStepLogs"
                  />
                </span>
              </div>
            </li>
          </ul>
          <ul class="cr-title-pad">
            <li class="question-count">
              <div>Question&nbsp;</div>
              <div v-html="this.latestQuestionInd"></div>
              <div>&nbsp;of&nbsp;</div>
              <div v-html="practiceQuestion.total_questions"></div>
            </li>
          </ul>
          <ul class="cr-submit-pad">
            <li>
              <div>
                <SubmitBtn
                  :totalQuestions="practiceQuestion.total_questions"
                  :questionContentArray="practiceQuestion.questions"
                  :stepLogId="stepLogId"
                  :practiceQuestionId="practiceQuestionId"
                  :hasValidSubscription="hasValidSubscription"
                  :isEmailVerified="isEmailVerified"
                  :preferredExamBodyId="preferredExamBodyId"
                  :quizType="practiceQuestion.kind"
                  :lessonName="moduleName"
                  :moduleName="moduleName"
                  :courseName="courseName"
                  :programName="programName"
                />
              </div>
            </li>
          </ul>
        </div>
      </div>
    </div>
    <div class="top-btns-prac-ques">
      <div class="cr-navigation lightBg">
        <div class="cr-navigation-left">
          <ul>
            <li id="open-calculator-dialog">
              <ModalCalculator class="top-btns-left-pane-spc" />
            </li>
            <li id="open-scratch-pad-dialog">
              <ModalScratchPad />
            </li>
          </ul>
        </div>
        <div class="cr-navigation-right">
          <ul>
            <li>
              <span v-if="practiceQuestion.kind == 'standard'">
                <ModalSolution
                  :solutionTitle="practiceQuestion.course_step.name"
                  :solutionContent="practiceQuestion.questions"
                />
              </span>
              <span v-else>
                <ModalSolutionV2
                  :solutionContentArray="practiceQuestion.solutions_v2"
                />
              </span>
            </li>
            <li>
              <HelpBtn :helpPdf="practiceQuestion.document.url" />
            </li>
          </ul>
        </div>
      </div>

      <div class="top-btns-left-pane">
        <CloseAllModals
          v-if="practiceQuestion.kind != 'standard'"
          class="top-btns-left-pane-spc"
        />
      </div>
    </div>
    <div class="questions" v-on:click="refreshSheetLayout()">
      <splitpanes
        class="practice-question-theme"
        :style="{ height: '70vh' }"
        :key="stepLogId"
        @resize="splitResize()"
      >
        <span v-if="practiceQuestion.kind == 'standard'">
          <ScenarioPane :content="practiceQuestion.content" />
        </span>
        <span v-else>
          <ExhibitsRequirementsPane
            :key="stepLogId"
            :totalQuestions="practiceQuestion.total_questions"
            :requirementContentArray="practiceQuestion.questions"
            :stepLogId="stepLogId"
            :practiceQuestionId="practiceQuestionId"
            :exhibitContentArray="practiceQuestion.exhibits"
            :responseContentArray="practiceQuestion.responses"
            :previousAttempts="previousStepLogs"
          />
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
          <ScenarioPane
            :content="practiceQuestion.content"
            class="practice-ques-single-question"
          />
        </span>
      </splitpanes>

      <div
        v-if="practiceQuestion.kind == 'standard'"
        :title="dynamicTitle"
        :class="{ outsidelastpage: outsideLastPage }"
      ></div>
      <div
        v-else
        :title="dynamicTitle"
        :class="{ outsidelastpage: outsideLastPage }"
      >
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
import CloseAllModals from "./CloseAllModals.vue";
import eventBus from "../cbe/EventBus.vue";
import ExhibitsRequirementsPane from "./ExhibitsRequirementsPane.vue";
import HelpBtn from "../../components/practiceQuestions/HelpBtn.vue";
import ModalCalculator from "./ModalCalculator.vue";
import ModalScratchPad from "./ModalScratchPad.vue";
import ModalSolution from "./ModalSolution.vue";
import ModalSolutionV2 from "./ModalSolutionV2.vue";
import PreviousAttempts from "./PreviousAttempts.vue";
import QuestionAnswers from "../../components/cbe/QuestionAnswers.vue";
import QuestionsAnswersPane from "./QuestionsAnswersPane.vue";
import ScenarioPane from "./ScenarioPane.vue";
import Splitpanes from "splitpanes";
import SubmitBtn from "../../components/practiceQuestions/SubmitBtn.vue";
import SubmitBtnV2 from "../../components/practiceQuestions/SubmitBtnV2.vue";

export default {
  components: {
    CloseAllModals,
    eventBus,
    ExhibitsRequirementsPane,
    HelpBtn,
    ModalCalculator,
    ModalScratchPad,
    ModalSolution,
    ModalSolutionV2,
    PreviousAttempts,
    QuestionAnswers,
    QuestionsAnswersPane,
    ScenarioPane,
    Splitpanes,
    SubmitBtn,
    SubmitBtnV2,
  },
  data() {
    return {
      stepLogId: this.$parent.stepLogId,
      previousStepLogs: this.$parent.stepLogs,
      practiceQuestionId: this.$parent.practiceQuestionId,
      practiceQuestion: null,
      hasValidSubscription: this.$parent.hasValidSubscription,
      isEmailVerified: this.$parent.isEmailVerified,
      preferredExamBodyId: this.$parent.preferredExamBodyId,
      courseName: this.$parent.courseName,
      programName: this.$parent.programName,
      moduleName: this.$parent.moduleName,
      zIndexArr: [
        "calcModal",
        "scratchPadModal",
        "solutionModal",
        "helpModal",
        "solutionModalV2",
        "textEditorModal",
        "spreadsheetModal",
      ],
      outsideLastPage: true,
      dynamicTitle: "All answers required before completing",
      lastPageIndex: null,
      isFetching: true,
      latestAnswer: false,
      latestQuestionInd: 1,
      updateAnsArr: null,
    };
  },
  created() {
    this.loadingPracticeQuestion();

    eventBus.$on("z-index-click", (lastClickedModal) => {
      this.zIndexSort(lastClickedModal);
      this.zIndexStyle(this.zIndexArr);
    }),
      eventBus.$on("update-answer-text", (ans) => {
        if (ans.length > 0) {
          this.latestAnswer = true;
          this.evaluateAnsText(true);
        } else {
          this.evaluateAnsText(false);
        }
      }),
      eventBus.$on("update-active-question-ind", (ans) => {
        if (ans > 1) {
          this.latestQuestionInd = ans;
        } else {
          this.latestQuestionInd = 1;
        }
      }),
      eventBus.$on("active-solution-index", (showSubmitBtn) => {
        if (showSubmitBtn[0]) {
          this.outsideLastPage = false;
          this.dynamicTitle = "Mark as Complete";
        } else {
          this.outsideLastPage = true;
          this.dynamicTitle = "All answers required before completing";
        }
      });
    eventBus.$on("active-solution-index-v2", (showSubmitBtn) => {
      if (showSubmitBtn) {
        this.outsideLastPage = false;
        this.dynamicTitle = "Mark as Complete";
      } else {
        this.outsideLastPage = true;
        this.dynamicTitle = "All answers required before completing";
      }
    });
    eventBus.$on("update-course_step-log", (log_id) => {
      this.getPracticeQuestion(log_id);
    });
  },
  mounted() {
    this.getPracticeQuestion(this.stepLogId);
  },
  methods: {
    getPracticeQuestion(log_id) {
      axios
        .get(
          `/api/v1/course_step_log/${log_id}/practice_questions/${this.practiceQuestionId}`
        )
        .then((response) => {
          this.practiceQuestion = response.data;
          this.isFetching = false;
          this.loader.hide();
          let fillArr = new Array(this.practiceQuestion.total_questions);
          this.updateAnsArr = fillArr.fill(0);
          this.zIndexLoadArr(
            this.practiceQuestion.exhibits,
            this.practiceQuestion.questions,
            this.practiceQuestion.responses
          );
          this.stepLogId = log_id;
          this.cbeInitialized(this.practiceQuestion);
        })
        .catch((e) => {});
    },
    cbeInitialized(pq) {
      sendClickEventToSegment("quiz_initiated", {
        userId: userId,
        email: email,
        hasValidSubscription: this.hasValidSubscription,
        isEmailVerified: this.isEmailVerified,
        preferredExamBodyId: this.preferredExamBodyId,
        isLoggedIn: isLoggedIn,
        sessionId: sessionId,
        quizType: "pq " + pq.kind,
        lessonName: this.moduleName,
        moduleName: this.moduleName,
        courseName: this.courseName,
        programName: this.programName,
      });
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
          document.getElementById(modalArr[index]).style.zIndex = 1099 - index;
        } catch (e) {}
      }
    },
    zIndexLoadArr(exh, ques, resp) {
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
        this.dynamicTitle = "Mark as Complete";
      } else {
        this.outsideLastPage = true;
        this.dynamicTitle = "All answers required before completing";
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
    refreshSheetLayout() {
      window.dispatchEvent(new Event("resize"));
    },
    splitResize() {
      var updatedWidth = Number($("#pane_1").width()) + 5;
      eventBus.$emit("splitpane-resize", updatedWidth.toString() + "px");
    },
  },
};
</script>
