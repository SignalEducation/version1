<template>
  <section>
    <div
      v-if="scenarioData.id == id"
      :key="id"
      class="scenarios"
    >
      <splitpanes
        class="default-theme"
        :style="{ height: height + 'px' }"
      >
        <pane min-size="20" size="31">
          <div class="exhibits-sidebar">
            <div class="exhibits">
              <section class="exhibits-sidebar-head">Exhibits</section>
              <CbeExhibitsModal
                v-for="exhibit in scenarioData.exhibits"
                :key="exhibit.id"
                :componentInd="exhibit.id"
                :componentType="exhibit.kind"
                :componentName="exhibit.name"
                :componentModal="exhibit.modal"
                :currentFile="exhibit.document"
                :componentContentData="exhibit.content"
                :componentIcon="'exhibit-icon'"
              />
            </div>

            <div class="requirements">
              <section class="exhibits-sidebar-head">Requirements</section>
              <CbeRequirementsModal
                v-for="requirement in scenarioData.requirements"
                :key="requirement.id"
                :componentModal="requirement.modal"
                :componentName="requirement.name + ' (' + requirement.score + ' marks)'"
                :componentContentData="requirement.content"
                :componentType="requirement.kind"
                :componentIcon="'requirement-icon'"
              />
            </div>

            <div class="response-options">
              <section class="exhibits-sidebar-head">Response Options</section>
              <CbeResponseOptionsModal
                v-for="response_option in scenarioData.response_options"
                :key="response_option.id"
                :responseOptionId="response_option.id"
                :responseOptionName="response_option.kind_formatted"
                :responseOptionType="response_option.kind"
                :responseOptionQuantity="response_option.quantity"
                :responseOptionModal="response_option.modal"
              />
            </div>
          </div>
        </pane>
        <pane>
          <section class="cbe-content-template" v-html="scenarioData.content" />
        </pane>
      </splitpanes>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex';
import Splitpanes from 'splitpanes';
import Pane from 'splitpanes';
import VueModal from '../../components/VueModal.vue';
import CbeExhibitsModal from '../../components/cbe/CbeExhibitsModal.vue';
import CbeRequirementsModal from '../../components/cbe/CbeRequirementsModal.vue';
import CbeResponseOptionsModal from '../../components/cbe/CbeResponseOptionsModal.vue';

export default {
  components: {
    Splitpanes,
    Pane,
    VueModal,
    CbeExhibitsModal,
    CbeRequirementsModal,
    CbeResponseOptionsModal,
  },
  props: {
    id: {
      type: [Number, String],
      required: true
    },
  },
  data() {
    return {
      height: 200,
    };
  },
  computed: {
    ...mapGetters('cbe', {
      cbeData: 'cbe_data',
    }),
    scenarioData() {
      let cbeScenario = {};
      const scenarioId = parseInt(this.id);

      if(this.cbeData !== null && scenarioId!== null) {
        cbeScenario = this.cbeData.scenarios.find(function(element) {
          return element.id === scenarioId;
        });
      }
      return cbeScenario;
    },
  },
  mounted() {
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  },
  methods: {
    handleResize() {
      const headerFooter =
        $('#cbe-nav-header').height() +
        $('#cbe-footer')
          .children()
          .first()
          .height();
      this.height = $(window).height() - headerFooter;
    },
    updateModal(status){
      this.scenarioData.exhibits[0].name = 'Gio test'
      this.$emit("update-close-all", status);
    }
  },
};
</script>
