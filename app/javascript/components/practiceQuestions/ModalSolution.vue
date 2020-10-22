<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex()" href="#solutionModal" class="btn btn-settings solution-btn-title" data-backdrop="false" data-toggle="modal">Solution</button>
        <div @click="updateZindex()" id="solutionModal" class="modal2-solution fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Solution</h4>

                    </div>
                    <div class="modal2-body">
                        <h3>{{solutionTitle}}</h3>
                        <h5>Question {{this.indexOfQuestion + 1}}</h5>
                        <div v-if="solutionContent[this.indexOfQuestion].kind === 'spreadsheet'">

                        </div>
                        <div v-else>
                          <p v-html="solutionContent[this.indexOfQuestion].solution"></p>
                        </div>
                        <div v-show="solutionContent[this.indexOfQuestion].kind == 'open'">
                          <p v-html="solutionContent[this.indexOfQuestion].solution"></p>
                        </div>
                        <div v-show="solutionContent[this.indexOfQuestion].kind == 'spreadsheet'">
                          <SpreadsheetEditor
                            :initial-data="solutionContent[this.indexOfQuestion].solution"
                            @spreadsheet-updated="syncSpreadsheetData"
                          />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor
  },
  props: {
  	solutionTitle: {
      type: String,
    },
    solutionContent: {
      type: [Object, Array],
    },
  },
  data() {
    return {
      modalIsOpen: false,
      indexOfQuestion: 0,
    };
  },
  created() {
    eventBus.$on("active-solution-index",(index)=>{
      this.indexOfQuestion = index;
    })
  },
  mounted() {
    this.$nextTick(function () {
        $('#solutionModal').draggable();
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit('z-index-click', 'solutionModal');
    },
    syncSpreadsheetData(jsonData) {
      this.$store.dispatch('userCbe/recordAnswer', {
        id: this.questionId,
        answers_attributes: [{
          content: {
            data: jsonData,
          },
        }],
      });
    },
  },
  watch: {
    modalStatus(status) {
      this.modalIsOpen = status;
    },
    modalIsOpen(value) {
      this.$emit("update-close-all", this.modalIsOpen);
    },

  },
};
</script>
