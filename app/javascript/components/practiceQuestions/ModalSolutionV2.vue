<template>
    <div>
      <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" href="#solutionModalV2" class="btn btn-settings solution-btn-title" data-backdrop="false" data-toggle="modal">Solution</button>
      <div @click="updateZindex()" id="solutionModalV2" class="modal2-solution fade resizemove" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                  <div class="modal2-header-lg">
                    <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal2-title">Solution</h4>
                  </div>
                  <div class="modal2-body">
                    <div class="modal-solution-wrapper">
                    <ul class="tabs clearfix" data-tabgroup="first-tab-group">
                      <li v-for="(solution, index) in solutionContentArray" :key="solution">
                        <a v-show="solution.kind == 'open'" :href="'#tab'+(index+1)" :class="{ 'active' : index == 0}">
                          <i class="material-icons exhibits-icon">create</i>
                          Text
                        </a>
                        <a v-show="solution.kind == 'spreadsheet'" :href="'#tab'+(index+1)" :class="{ 'active' : index == 0}">
                          <i class="material-icons exhibits-icon">table_view</i>
                          Spreadsheet
                        </a>
                      </li>
                    </ul>
                    <section id="first-tab-group" class="tabgroup">
                      <div v-for="(solution, index) in solutionContentArray" :key="solution" :id="'tab'+(index+1)" class="tabgroup-pad">
                        <div v-show="solution.kind == 'open'">
                          <p v-html="solution.content"></p>
                        </div>
                        <div v-show="solution.kind == 'spreadsheet'">
                          <SpreadsheetEditor
                            :initial-data="solution.content"
                            :key="solution.id"
                            @spreadsheet-updated="syncSpreadsheetData"
                          />
                        </div>
                      </div>
                    </section>
                    </div>
                </div>
              </div>
          </div>
          <div class="draggable-overlay"></div>
        </div>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
  },
  props: {
    solutionContentArray: {
      type: [Object, Array],
    },
  },
  data() {
    return {
      modalIsOpen: false,
      indexOfQuestion: 0,
      solutionObj: null,
      textBool: null,
    };
  },
  async created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    });
  },
  mounted() {
    this.$nextTick(function () {
      $('#solutionModalV2').draggable({ handle:'.modal2-header-lg, .draggable-overlay'});
    })
    this.instantiateTabs()
    this.convertStr2Obj(this.solutionContentArray)
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      this.solutionContentArray[1].solution.content = { content: { data: jsonData } };
    },
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit("z-index-click", "solutionModalV2");
    },
    resetModalDims() {
      $('#solutionModalV2').css('width', '60em');
      $('#solutionModalV2').css('height', '37em');
    },
    instantiateTabs() {
      $('.tabgroup > div').hide();
      $('.tabgroup > div:first-of-type').show();
      $('.tabs a').click(function(e){
        e.preventDefault();
          var $this = $(this),
              tabgroup = '#'+$this.parents('.tabs').data('tabgroup'),
              others = $this.closest('li').siblings().children('a'),
              target = $this.attr('href');
          others.removeClass('active');
          $this.addClass('active');
          $(tabgroup).children('div').hide();
          $(target).show();

      });
    },
    convertStr2Obj(arr) {
      for (var i in arr) {
        if (arr[i].kind == "spreadsheet") {
          arr[i].content = JSON.parse(arr[i].content);
        }
      }
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
