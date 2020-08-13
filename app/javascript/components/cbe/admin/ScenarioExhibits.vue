<template>
  <div>
    <div v-for="exhibit in scenarioObject.exhibits" :key="exhibit.id">
      <b-card no-body class="mb-1">
        <b-card-header header-tag="header" class="p-1" role="tab">
          <b-button
            v-b-toggle="'accordion-' + exhibit.id"
            block
            href="#"
            variant="secondary"
          >
            Exhibit - {{ exhibit.sorting_order }}
          </b-button>
        </b-card-header>

        <b-collapse
          :id="'accordion-' + exhibit.id"
          accordion="exhibit-accordion"
          role="tabpanel"
        >
          <b-card-body>
            <div v-if="exhibit.kind == 'pdf'">
              <ExhibitForm
              :id="exhibit.id"
              :initialName="exhibit.name"
              :initialKind="exhibit.kind"
              :initialFile="exhibit.document"
              :initialSortingOrder="exhibit.sorting_order"
              :scenario-id="scenarioObject.id"
              @add-scenario-exhibit="addScenarioExhibit"
              @rm-scenario-exhibit="rmScenarioExhibit"
            />
            </div>
            <div v-else>
              <ExhibitForm
              :id="exhibit.id"
              :initialName="exhibit.name"
              :initialKind="exhibit.kind"
              :initalContent="exhibit.content"
              :initialSortingOrder="exhibit.sorting_order"
              :scenario-id="scenarioObject.id"
              @add-scenario-exhibit="addScenarioExhibit"
              @rm-scenario-exhibit="rmScenarioExhibit"
            />
            </div>

          </b-card-body>
        </b-collapse>
      </b-card>
    </div>

    <b-card no-body class="mb-1">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button
          v-b-toggle.new-exhibit-accordion
          block
          href="#"
          variant="primary"
        >
          New Exhibit
        </b-button>
      </b-card-header>

      <b-collapse
        id="new-exhibit-accordion"
        visible
        accordion="my-accordion"
        role="tabpanel"
      >
        <b-card-body>
          <div class="row">
            <ExhibitForm
              :scenario-id="scenarioObject.id"
              @add-scenario-exhibit="addScenarioExhibit"
            />
          </div>
        </b-card-body>
      </b-collapse>
    </b-card>
  </div>
</template>

<script>
import axios from "axios";
import { validationMixin } from "vuelidate";
import { required, numeric } from "vuelidate/lib/validators";
import ExhibitForm from "./ExhibitForm.vue";
import SpreadsheetEditor from "../../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    ExhibitForm,
    SpreadsheetEditor,
  },
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    initialName: {
      type: String,
      default: "",
    },
    initialKind: {
      type: String,
      default: "pdf",
    },
    initalContent: {
      type: Object,
      default: () => ({}),
    },
    initialFile: {
      type: Object,
      default: () => ({}),
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    scenarioObject: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      exhibitsDetails: {},
      name: this.initialName,
      sortingOrder: this.initialSortingOrder,
      exhibitKind: this.initialKind,
      exhibitContent: this.initalContent,
      file: this.initialFile,
      attachedFile: null,
      submitStatus: null,
      updateStatus: null,
    };
  },
  validations: {
    name: {
      required,
    },
    sortingOrder: {
      required,
      numeric,
    },
    file: {},
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : "New Exhibit";
    },
  },

  methods: {
    addScenarioExhibit(data) {
      this.$emit("add-scenario-exhibit", data);
    },

    rmScenarioExhibit(data) {
      this.$emit("rm-scenario-exhibit", data);
    },
  },
};
</script>
