<template>
  <section>
    <div class="practice-question-V2" style="padding:15px;">
      <div class="practice-question-section">
        <div class="practice-question-v2-title">Previous Attempts</div>
        <span v-for="(log) in previousAttempts" :key="log.id">
          <span class="practice-question-left-pane">
            <button @click="updateCourseStepLog(log.id)" class="learn-more">
              <div class="circle"><span class="icon arrow"></span></div>
              <span class="button-text">
                <i class="material-icons exhibits-icon">schedule</i>
                  <p>{{ log.created }}</p>
                </span>
            </button>
          </span>
        </span>
      </div>
    </div>
  </section>
</template>

<script>
function rightPaneScrolling() {
  let isScrolling;
  if (document.getElementById("rightPaneTopUnderline") != null) {
    if ($("#pane_1").scrollTop() == 0) {
      setTimeout(() => {
        document.getElementById("rightPaneTopUnderline").style.display = "none";
      }, 500);
    }
    document.getElementById("rightPaneTopUnderline").style.display = "block";
  }
  window.clearTimeout( isScrolling );
}

import axios from "axios";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus,
  },
  props: {
    stepLogId: {
      type: [String, Number],
    },
    previousAttempts: {
      type: [Array, Object]
    },
  },
  methods: {
    updateCurrentResponse: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            responses: this.responseContentArray,
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
    updateCourseStepLog: function(log_id) {
      eventBus.$emit("update-course_step-log", log_id);
    },
  },
};
</script>
