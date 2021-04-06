<template>
    <div class="submit-btn-modal">
        <button @click="modalIsOpen = !modalIsOpen; nextStepCounter()" :disabled="hideSubmitBtn" href="#submitModal" class="btn btn-settings submit-btn-title" data-backdrop="false" data-toggle="modal"  data-target=".bs-example-modal-new"></button>
        <div class="modal fade bs-example-modal-new" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
            <div class="modal-header">
                <h4>Step Completed</h4>
                <button @click="cancelNavigation" type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            </div>
              <div class="modal-body">
                <div class="body-message">
                  <p>You'll be redirected to the next step in {{ timerCount }} seconds...</p>
                </div>
              </div>
              <div class="modal-footer">
                <button @click="cancelNavigation" type="button" class="btn btn-submit-modal-outline" data-dismiss="modal">Stay Here</button>
                <button @click="navigateToNextStep" type="button" class="btn btn-submit-modal" data-dismiss="modal">Next Step</button>
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
    sendResponseArraytoDB: {
      type: Array,
    },
    stepLogId: {
      type: [String, Number],
    },
    practiceQuestionId: {
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
    eventBus.$on("show-submit-v2-btn",(showBool)=>{
      if (showBool) {
        this.hideSubmitBtn = false;
      } else {
        this.hideSubmitBtn = true;
      }
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    nextStepCounter() {
      this.stayHere = false;
      this.timerCount = 5;
      this.updateCurrentResponse();
      practiceQuestionCompleted();
    },
    navigateToNextStep() {
      $(".practice-ques-next-step")[0].click();
    },
    cancelNavigation() {
      this.stayHere = true;
      this.timerCount = 5;
    },
    updateCurrentResponse: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            responses: this.sendResponseArraytoDB,
            status: 'submited'
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
      immediate: true
    }
  },
};
</script>
