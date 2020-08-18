<template>
  <div>
    <div v-for="response_option in scenarioObject.response_options" :key="response_option.id">
      <b-card no-body class="mb-1">
        <b-card-header header-tag="header" class="p-1" role="tab">
          <b-button
            v-b-toggle="'accordion-' + response_option.id"
            block
            href="#"
            variant="secondary"
          >
          {{ response_option.sorting_order }} - {{ response_option.kind_formatted }}
          </b-button>
        </b-card-header>

        <b-collapse
          :id="'accordion-' + response_option.id"
          accordion="response-option-accordion"
          role="tabpanel"
        >
          <b-card-body>
            <responseOptionForm
              :id="response_option.id"
              :initialKind="response_option.kind"
              :initialSortingOrder="response_option.sorting_order"
              :initialQuantity="response_option.quantity"
              :scenario-id="scenarioObject.id"
              @rm-scenario-response-option="rmScenarioResponseOption"
            />

          </b-card-body>
        </b-collapse>
      </b-card>
    </div>

    <b-card no-body class="mb-1">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button
          v-b-toggle.new-response_option-accordion
          block
          href="#"
          variant="primary"
        >
          New Response Option
        </b-button>
      </b-card-header>

      <b-collapse
        visible
        id="new-response-option-accordion"
        accordion="response-option-accordion"
        role="tabpanel"
      >
        <b-card-body>
          <div class="row">
            <responseOptionForm
              :scenario-id="scenarioObject.id"
              @add-scenario-response-option="addScenarioResponseOption"
            />
          </div>
        </b-card-body>
      </b-collapse>
    </b-card>
  </div>
</template>

<script>
import responseOptionForm from "./ResponseOptionForm.vue";

export default {
  components: {
    responseOptionForm,
  },
  props: {
    scenarioObject: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : "New Response Option";
    },
  },

  methods: {
    addScenarioResponseOption(data) {
      this.$emit("add-scenario-response-option", data);
    },

    rmScenarioResponseOption(data) {
      this.$emit("rm-scenario-response-option", data);
    },
  },
};
</script>
