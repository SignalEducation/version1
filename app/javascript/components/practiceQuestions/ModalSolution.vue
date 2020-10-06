<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen" href="#solutionModal" class="btn btn-settings solution-btn-title" data-backdrop="false" data-toggle="modal">Solution</button>
        <div id="solutionModal" class="modal2 fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Solution</h4>

                    </div>
                    <div class="modal2-body">
                        <h3>{{solutionTitle}}</h3>
                        <h5>Question {{this.indexOfQuestion + 1}}</h5>
                        <p v-html="solutionContent[this.indexOfQuestion].solution"></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus
  },
  props: {
  	solutionTitle: {
      type: String,
    },
    solutionContent: {
      type: Object,
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
      console.log("index: ", index);
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
    }
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