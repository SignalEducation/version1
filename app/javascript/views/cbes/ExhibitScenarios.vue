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
                :exhibitType="exhibit.kind"
                :exhibitName="exhibit.name"
                :exhibitModal="exhibit.modal"
                :currentFile="exhibit.document"
                :exhibitSpreadsheetData="exhibit.content"
              />
            </div>

            <div class="requirements">
              <section class="exhibits-sidebar-head">Requirements</section>
              <CbeRequirementsModal
                v-for="requirement in scenarioData.requirements"
                :key="requirement.id"
                :requirementModal="requirement.modal"
                :requirementScore="requirement.score"
                :requirementName="requirement.name"
                :requirementContent="requirement.content"
                :requirementType="requirement.kind"
              />
            </div>

            <div class="response-options">
              <section class="exhibits-sidebar-head">Response Options</section>
              <CbeResponseOptionsModal
                v-for="response_option in scenarioData.response_options"
                :key="response_option.id"
                :responseOptionId="response_option.id"
                :responseOptionName="response_option.name"
                :responseOptionType="response_option.kind"
                :responseOptionFType="response_option.kind_formatted"
                :responseOptionQuantity="response_option.quantity"
                :responseOptionModal="response_option.modal"
              />
            </div>
          </div>
        </pane>
        <pane>
          <section v-html="scenarioData.content" />
        </pane>
      </splitpanes>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex';
import Splitpanes from 'splitpanes';
import Pane from 'splitpanes';
import CbeExhibitsModal from '../../components/cbe/CbeExhibitsModal.vue';
import CbeRequirementsModal from '../../components/cbe/CbeRequirementsModal.vue';
import CbeResponseOptionsModal from '../../components/cbe/CbeResponseOptionsModal.vue';

export default {
  components: {
    Splitpanes,
    Pane,
    CbeExhibitsModal,
    CbeRequirementsModal,
    CbeResponseOptionsModal,
  },
  props: {
    id: {
      type: Number,
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
      const scenarioId = this.id;

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
  },
};
</script>
