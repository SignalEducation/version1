<template>
  <div class="submit-btn-modal">
    <a
      @click="
        modalIsOpen = !modalIsOpen;
        nextStepCounter();
        cbeCompleted();
      "
      :disabled="hideSubmitBtn"
      href="#submitModal"
      class="cr-nav-link exit-btn submit-btn-title"
      data-backdrop="false"
      data-toggle="modal"
      data-target=".bs-example-modal-new"
    >
    </a>
    <div
      class="modal fade bs-example-modal-new"
      tabindex="-1"
      role="dialog"
      aria-labelledby="myLargeModalLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4>Step Completed</h4>
            <button
              @click="cancelNavigation"
              type="button"
              class="close"
              data-dismiss="modal"
              aria-label="Close"
            >
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="body-message">
              <p>
                You'll be redirected to the next step in
                {{ timerCount }} seconds...
              </p>
            </div>
          </div>
          <div class="modal-footer">
            <button
              @click="cancelNavigation"
              type="button"
              class="btn btn-submit-modal-outline"
              data-dismiss="modal"
            >
              Stay Here
            </button>
            <button
              @click="navigateToNextStep"
              type="button"
              class="btn btn-submit-modal"
              data-dismiss="modal"
            >
              Next Step
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// TODO: Refactor code to make this modal an independent component not just for submit button

import axios from "axios";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus,
  },
  props: {
    totalQuestions: {
      type: Number,
    },
    questionContentArray: {
      type: Array,
    },
    stepLogId: {
      type: [String, Number],
    },
    practiceQuestionId: {
      type: [String, Number],
    },
    hasValidSubscription: {
      type: [String, Number],
    },
    isEmailVerified: {
      type: [String, Number],
    },
    quizType: {
      type: [String, Number],
    },
    lessonName: {
      type: [String, Number],
    },
    moduleName: {
      type: [String, Number],
    },
    courseName: {
      type: [String, Number],
    },
    programName: {
      type: [String, Number],
    },
  },
  data() {
    return {
      hideSubmitBtn: true,
      modalIsOpen: false,
      timerCount: null,
      stayHere: false,
    };
  },
  created() {
    eventBus.$on("show-submit-btn", (showBool) => {
      this.hideSubmitBtn = !showBool;
    });
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    nextStepCounter() {
      this.stayHere = false;
      this.timerCount = 5;
      this.updateCurrentAnswer();
    },
    navigateToNextStep() {
      $(".practice-ques-next-step")[0].click();
    },
    cancelNavigation() {
      this.stayHere = true;
      this.timerCount = 5;
    },
    cbeCompleted() {
      sendClickEventToSegment("quiz_completed", {
        userId: userId,
        email: email,
        hasValidSubscription: this.hasValidSubscription,
        isEmailVerified: this.isEmailVerified,
        preferredExamBodyId: this.preferredExamBodyId,
        isLoggedIn: isLoggedIn,
        sessionId: sessionId,
        quizType: "pq " + this.quizType,
        lessonName: this.moduleName,
        moduleName: this.moduleName,
        courseName: this.courseName,
        programName: this.programName,
      });
    },
    updateCurrentAnswer: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            practice_questions: this.questionContentArray,
            status: "submited",
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
  },
  watch: {
    modalStatus(status) {
      this.modalIsOpen = status;
    },
    modalIsOpen(value) {
      this.$emit("update-close-all", this.modalIsOpen);
    },
    timerCount: {
      handler(value) {
        if (value > 0) {
          setTimeout(() => {
            this.timerCount--;
            if (this.timerCount == 0 && !this.stayHere) {
              $(".practice-ques-next-step")[0].click();
            }
          }, 1000);
        }
      },
      immediate: true,
    },
  },
};
</script>
