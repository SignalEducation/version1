<template>
  <div>
    <div v-for="requirement in scenarioObject.requirements" :key="requirement.id">
      <b-card no-body class="mb-1">
        <b-card-header header-tag="header" class="p-1" role="tab">
          <b-button
            v-b-toggle="'accordion-' + requirement.id"
            block
            href="#"
            variant="secondary"
          >
            Requirement - {{ requirement.sorting_order }}
          </b-button>
        </b-card-header>

        <b-collapse
          :id="'accordion-' + requirement.id"
          accordion="requirement-accordion"
          role="tabpanel"
        >
          <b-card-body>
            <RequirementForm
              :id="requirement.id"
              :initialName="requirement.name"
              :initialKind="requirement.kind"
              :initialScore="requirement.score"
              :initialSortingOrder="requirement.sorting_order"
              :initialContent="requirement.content"
              :scenario-id="scenarioObject.id"
              @rm-scenario-requirement="rmScenarioRequirement"
            />

          </b-card-body>
        </b-collapse>
      </b-card>
    </div>

    <b-card no-body class="mb-1">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button
          v-b-toggle.new-requirement-accordion
          block
          href="#"
          variant="primary"
        >
          New Requirement
        </b-button>
      </b-card-header>

      <b-collapse
        visible
        id="new-requirement-accordion"
        accordion="my-accordion"
        role="tabpanel"
      >
        <b-card-body>
          <div class="row">
            <RequirementForm
              :scenario-id="scenarioObject.id"
              @add-scenario-requirement="addScenarioRequirement"
            />
          </div>
        </b-card-body>
      </b-collapse>
    </b-card>
  </div>
</template>

<script>
import RequirementForm from "./RequirementForm.vue";

export default {
  components: {
    RequirementForm,
  },
  props: {
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    scenarioObject: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : "New Rxhibit";
    },
  },

  methods: {
    addScenarioRequirement(data) {
      this.$emit("add-scenario-requirement", data);
    },

    rmScenarioRequirement(data) {
      this.$emit("rm-scenario-requirement", data);
    },
  },
};
</script>
