<template>
  <div class="panel-body no-top-padding">
    <div>
      <div class="row">
        <div class="col-sm-12 mb-2">
          <div v-if="this.$store.state.cbeDetailsSaved === true">
            <b-button
              :class="shouldShowCbeDetails ? 'collapsed mr-1' : 'mr-1'"
              :aria-expanded="shouldShowCbeDetails ? 'true' : 'false'"
              aria-controls="collapse-cbe"
              variant="primary"
              @click="toggleCbeDetails"
            >
              <span class="when-opened">&#10514;</span>
              <span class="when-closed">&#10515;</span> CBE Details
            </b-button>
            <b-button
              :class="shouldShowIntroPages ? 'collapsed mr-1' : 'mr-1'"
              :aria-expanded="shouldShowIntroPages ? 'true' : 'false'"
              aria-controls="collapse-intro-pages"
              variant="primary"
              @click="toggleIntroPages"
            >
              <span class="when-opened">&#10514;</span>
              <span class="when-closed">&#10515;</span> Intro Pages
            </b-button>
            <b-button
              :class="shouldShowResources ? 'collapsed mr-1' : 'mr-1'"
              :aria-expanded="shouldShowResources ? 'true' : 'false'"
              aria-controls="collapse-resources"
              variant="primary"
              @click="toggleResources"
            >
              <span class="when-opened">&#10514;</span>
              <span class="when-closed">&#10515;</span> Resources
            </b-button>
          </div>
        </div>
      </div>
    </div>

    <div>
      <b-collapse
        id="collapse-cbe"
        v-model="showCbeDetails"
        class="mb-2"
      >
        <b-card>
          <Details />
        </b-card>
      </b-collapse>
      <div
        v-if="this.$store.state.cbeDetailsSaved === true"
        class="mt-2"
      >
        <b-collapse
          id="collapse-intro-pages"
          v-model="showIntroPages"
          class="mb-2"
        >
          <b-card no-body>
            <b-tabs card>
              <IntroductionPage
                v-for="page in introPages"
                :id="page.id"
                :key="'intro-page-tab-' + page.id"
                :initial-title="page.title"
                :initial-sorting-order="page.sorting_order"
                :initial-kind="page.kind"
                :initial-content="page.content"
                @rm-introduction-page="removePage"
              />
              <IntroductionPage
                :initial-sorting-order="sortingOrderValue(introPages)"
                @add-introduction-page="updatePages"
              />
            </b-tabs>
          </b-card>
        </b-collapse>

        <b-collapse
          id="collapse-resources"
          v-model="showResources"
          class="mb-2"
        >
          <Resources
            :resources="resources"
            @add-resource="updateResources"
            @rm-resource="removeResource"
          />
        </b-collapse>

        <h3>Exam Content</h3>
        <b-card no-body>
          <b-tabs card>
            <b-tab
              v-for="section in sections"
              :key="'section-tab-' + section.id"
              :title="section.name"
            >
              <div class="row">
                <div class="col-sm-10">
                  <b-collapse
                    :id="'section-edit-collapse-' + section.id"
                    class="mt-2"
                  >
                    <b-card>
                      <Section
                        :id="parseInt(section.id)"
                        :initial-name="section.name"
                        :initial-score="section.score"
                        :initial-sorting-order="section.sorting_order"
                        :initial-kind="section.kind"
                        :initial-random="section.random"
                        :initial-content="section.content"
                        @rm-section="removeSection"
                      />
                    </b-card>
                  </b-collapse>
                  <b-card>
                    <p>
                      Name: {{ section.name }} - Type: {{ section.kind }} -
                      Score: {{ section.score }}
                    </p>
                  </b-card>
                </div>
                <div class="col-sm-2">
                  <b-button
                    v-b-toggle="'section-edit-collapse-' + section.id"
                    variant="secondary"
                    class="mr-1"
                  >
                    Edit Section
                  </b-button>
                </div>
              </div>

              <hr>

              <div v-if="section.kind === 'objective'">
                <div
                  v-for="(question) in section.questions"
                  :key="question.id"
                >
                  <b-card
                    no-body
                    class="mb-1"
                  >
                    <b-card-header
                      header-tag="header"
                      class="p-1"
                      role="tab"
                    >
                      <b-button
                        v-b-toggle="'accordion-' + question.id"
                        block
                        href="#"
                        variant="secondary"
                      >
                        Question - {{ question.sorting_order }}
                      </b-button>
                    </b-card-header>

                    <b-collapse
                      :id="'accordion-'+ question.id"
                      accordion="my-accordion"
                      role="tabpanel"
                    >
                      <b-card-body>
                        <div class="row">
                          <div class="col-sm-12">
                            <Question
                              :id="question.id"
                              :section-id="section.id"
                              :section-kind="section.kind"
                              :initial-content="question.content"
                              :initial-solution="question.solution"
                              :initial-score="question.score"
                              :initial-sorting-order="question.sorting_order"
                              :initial-kind="question.kind"
                              :initial-answers="question.answers"
                              @rm-question="removeQuestion"
                            />
                          </div>
                        </div>
                      </b-card-body>
                    </b-collapse>
                  </b-card>
                </div>
                <b-card
                  no-body
                  class="mb-1"
                >
                  <b-card-header
                    header-tag="header"
                    class="p-1"
                    role="tab"
                  >
                    <b-button
                      v-b-toggle.new-question-accordion
                      block
                      href="#"
                      variant="primary"
                    >
                      New Question
                    </b-button>
                  </b-card-header>

                  <b-collapse
                    id="new-question-accordion"
                    visible
                    accordion="my-accordion"
                    role="tabpanel"
                  >
                    <b-card-body>
                      <Question
                        :section-id="section.id"
                        :section-kind="section.kind"
                        :initial-sorting-order="sortingOrderValue(section.questions)"
                        @add-question="updateQuestions"
                      />
                    </b-card-body>
                  </b-collapse>
                </b-card>
              </div>

              <div v-else>
                <div class="row">
                  <div class="col-sm-12">
                    <b-card no-body>
                      <b-tabs
                        pills
                        card
                        vertical
                        nav-wrapper-class="w-5"
                      >
                        <b-tab
                          v-for="scenario in section.scenarios"
                          :key="'scenario-tab-' + scenario.id"
                          :title="scenario.name"
                        >
                          <b-card-text>
                            <div class="row">
                              <div class="col-sm-10">
                                <b-collapse
                                  :id="'scenario-edit-collapse-' + scenario.id"
                                  class="mt-2"
                                >
                                  <b-card>
                                    <Scenario
                                      :id="scenario.id"
                                      :initial-name="scenario.name"
                                      :initial-content="scenario.content"
                                      @rm-scenario="removeScenario"
                                    />
                                  </b-card>
                                </b-collapse>
                                <b-card>
                                  <p>Name: {{ scenario.name }}</p>
                                </b-card>
                              </div>
                              <div class="col-sm-2">
                                <b-button
                                  v-b-toggle="
                                    'scenario-edit-collapse-' + scenario.id
                                  "
                                  variant="secondary"
                                  class="mr-1"
                                >
                                  Edit Scenario
                                </b-button>
                              </div>
                            </div>
                            <br>
                            <!-- here starts scenario exhibits -->
                            <div v-if="section.kind === 'exhibits_scenario'">
                              <div>
                                <b-card no-body>
                                  <b-tabs pills card>
                                    <b-tab title="Exhibits" >
                                      <ScenarioExhibits
                                      :scenario-object="scenario"
                                      @add-scenario-exhibit="updateScenarioExhibits"
                                      @rm-scenario-exhibit="removeScenarioExhibit" />
                                    </b-tab>

                                    <b-tab title="Requirements">
                                      <ScenarioRequirements
                                      :scenario-object="scenario"
                                      @add-scenario-requirement="updateScenarioRequirements"
                                      @rm-scenario-requirement="removeScenarioRequirement" />
                                    </b-tab>

                                    <b-tab title="Response Options">
                                      <ScenarioResponseOptions
                                        :scenario-object="scenario"
                                        @add-scenario-response-option="updateScenarioResponseOptions"
                                        @rm-scenario-response-option="removeScenarioResponseOption"
                                      />
                                    </b-tab>
                                  </b-tabs>
                                </b-card>
                              </div>
                            </div>
                            <!-- here ends scenario exhibits -->

                            <!-- here starts scenario questions -->
                            <div v-else>
                              <div
                                v-for="question in scenario.questions"
                                :key="question.id"
                              >
                                <b-card
                                  no-body
                                  class="mb-1"
                                >
                                  <b-card-header
                                    header-tag="header"
                                    class="p-1"
                                    role="tab"
                                  >
                                    <b-button
                                      v-b-toggle="'accordion-' + question.id"
                                      block
                                      href="#"
                                      variant="secondary"
                                    >
                                      Question - {{ question.sorting_order }}
                                    </b-button>
                                  </b-card-header>

                                  <b-collapse
                                    :id="'accordion-'+ question.id"
                                    accordion="question-accordion"
                                    role="tabpanel"
                                  >
                                    <b-card-body>
                                      <div class="row">
                                        <div class="col-sm-12">
                                          <b-card>
                                            <Question
                                              :id="question.id"
                                              :section-id="section.id"
                                              :section-kind="section.kind"
                                              :scenario-id="scenario.id"
                                              :initial-solution="question.solution"
                                              :initial-sorting-order="question.sorting_order"
                                              :initial-content="question.content"
                                              :initial-score="question.score"
                                              :initial-kind="question.kind"
                                              @rm-question="removeScenarioQuestion"
                                            />
                                          </b-card>
                                        </div>
                                      </div>
                                    </b-card-body>
                                  </b-collapse>
                                </b-card>
                              </div>
                            </div>

                            <b-card
                              no-body
                              class="mb-1"
                            >
                              <b-card-header
                                header-tag="header"
                                class="p-1"
                                role="tab"
                              >
                                <b-button
                                  v-b-toggle.new-question-accordion
                                  block
                                  href="#"
                                  variant="primary"
                                >
                                  New Question
                                </b-button>
                              </b-card-header>

                              <b-collapse
                                id="new-question-accordion"
                                visible
                                accordion="my-accordion"
                                role="tabpanel"
                              >
                                <b-card-body>
                                  <Question
                                    :section-id="section.id"
                                    :section-kind="section.kind"
                                    :scenario-id="scenario.id"
                                    :initial-sorting-order="sectionSortingOrderValue(section)"
                                    @add-question="updateScenarioQuestions"
                                  />
                                </b-card-body>
                              </b-collapse>
                            </b-card>
                          </b-card-text>
                        </b-tab>
                        <b-tab title="New Scenario">
                          <b-card-text>
                            <Scenario
                              :section-id="section.id"
                              @add-scenario="updateScenarios"
                            />
                          </b-card-text>
                        </b-tab>
                      </b-tabs>
                    </b-card>
                  </div>
                </div>
              </div>
            </b-tab>
            <b-tab title="New Section">
              <Section
                :initial-sorting-order="sortingOrderValue(sections)"
                @add-section="updateSections"
              />
            </b-tab>
          </b-tabs>
        </b-card>
      </div>
    </div>
  </div>
</template>

<script>
import Details from './Details.vue';
import IntroductionPage from './IntroductionPage.vue';
import Question from './Question.vue';
import Resources from './Resources.vue';
import Section from './Section.vue';
import Scenario from './Scenario.vue';
import ScenarioExhibits from './ScenarioExhibits.vue';
import ScenarioRequirements from './ScenarioRequirements.vue';
import ScenarioResponseOptions from './ScenarioResponseOptions.vue';

export default {
  components: {
    Details,
    IntroductionPage,
    Question,
    Resources,
    Section,
    Scenario,
    ScenarioExhibits,
    ScenarioRequirements,
    ScenarioResponseOptions,
  },
  data() {
    return {
      cbeDetails: [],
      sections: [],
      introPages: [],
      resources: [],
      showIntroPages: false,
      showCbeDetails: true,
      showResources: false,
    };
  },
  computed: {
    shouldShowCbeDetails() {
      return (
        this.showCbeDetails && !(this.showIntroPages || this.showResources)
      );
    },
    shouldShowIntroPages() {
      return (
        this.showIntroPages && !(this.showCbeDetails || this.showResources)
      );
    },
    shouldShowResources() {
      return (
        this.showResources && !(this.showCbeDetails || this.showIntroPages)
      );
    },
  },
  methods: {
    toggleCbeDetails() {
      this.showCbeDetails = !this.showCbeDetails;
      if (this.showCbeDetails && (this.showIntroPages || this.showResources)) {
        this.showIntroPages = false;
        this.showResources = false;
      }
    },
    toggleIntroPages() {
      this.showIntroPages = !this.showIntroPages;
      if (this.showIntroPages && (this.showCbeDetails || this.showResources)) {
        this.showCbeDetails = false;
        this.showResources = false;
      }
    },
    toggleResources() {
      this.showResources = !this.showResources;
      if (this.showResources && (this.showCbeDetails || this.showIntroPages)) {
        this.showCbeDetails = false;
        this.showIntroPages = false;
      }
    },
    updateSections(data) {
      this.sections.push(data);
    },
    removeSection(sectionId) {
      const filtered = this.sections.filter((section) => section.id !== sectionId);

      this.sections = filtered;
    },
    updatePages(data) {
      this.introPages.push(data);
    },
    removePage(pageid) {
      const filtered = this.introPages.filter((page) => page.id !== pageid);

      this.introPages = filtered;
    },
    updateResources(data) {
      this.resources.push(data);
    },
    removeResource(resourceId) {
      const filtered = this.resources.filter((resource) => resource.id !== resourceId);

      this.resources = filtered;
    },
    updateScenarios(data) {
      let sectionIndex = 0;
      this.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      const currentSection = this.sections[sectionIndex];
      if (!currentSection.hasOwnProperty('scenarios')) {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentSection, 'scenarios', []);
      }
      currentSection.scenarios.push(data);
    },
    removeScenario(data) {
      const filtered =
        this.sections.filter(function(section){
          section.scenarios = section.scenarios.filter((scenario) => scenario.id !== data.scenarioId);
          return section
        });

      this.sections = filtered;
    },
    updateScenarioExhibits(data) {
      let scenarioIndex = 0;
      let sectionIndex = 0;

      this.sections.forEach((section, index) => {
        section.scenarios.forEach((scenario, i) => {
          if (scenario.id === data.scenario_id) {
            sectionIndex = index;
            scenarioIndex = i;
          }
        });
      });
      const currentScenario = this.sections[sectionIndex].scenarios[scenarioIndex];
      if (!('exhibits' in currentScenario)) {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentScenario, 'exhibits', []);
      }
      currentScenario.exhibits.push(data);
    },
    removeScenarioExhibit(data) {
      const filtered =
        this.sections.filter(function(section){
          section.scenarios.filter(function(scenario){
            scenario.exhibits = scenario.exhibits.filter((exhibit) => exhibit.id !== data);
            return scenario
          });
          return section
        });

      this.sections = filtered;
    },
    updateScenarioRequirements(data) {
      let scenarioIndex = 0;
      let sectionIndex = 0;

      this.sections.forEach((section, index) => {
        section.scenarios.forEach((scenario, i) => {
          if (scenario.id === data.scenario_id) {
            sectionIndex = index;
            scenarioIndex = i;
          }
        });
      });
      const currentScenario = this.sections[sectionIndex].scenarios[scenarioIndex];
      if (!('requirements' in currentScenario)) {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentScenario, 'requirements', []);
      }
      currentScenario.requirements.push(data);
    },
    removeScenarioRequirement(data) {
      const filtered =
        this.sections.filter(function(section){
          section.scenarios.filter(function(scenario){
            scenario.requirements = scenario.requirements.filter((requirement) => requirement.id !== data);
            return scenario
          });
          return section
        });

      this.sections = filtered;
    },
    updateScenarioResponseOptions(data) {
      let scenarioIndex = 0;
      let sectionIndex = 0;

      this.sections.forEach((section, index) => {
        section.scenarios.forEach((scenario, i) => {
          if (scenario.id === data.scenario_id) {
            sectionIndex = index;
            scenarioIndex = i;
          }
        });
      });
      const currentScenario = this.sections[sectionIndex].scenarios[scenarioIndex];
      if (!('response_options' in currentScenario)) {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentScenario, 'response_options', []);
      }
      currentScenario.response_options.push(data);
    },
    removeScenarioResponseOption(data) {
      const filtered =
        this.sections.filter(function(section){
          section.scenarios.filter(function(scenario){
            scenario.response_options = scenario.response_options.filter((response_option) => response_option.id !== data);
            return scenario
          });
          return section
        });

      this.sections = filtered;
    },
    updateQuestions(data) {
      let sectionIndex = 0;
      this.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      const currentSection = this.sections[sectionIndex];
      if (!('questions' in currentSection)) {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentSection, 'questions', []);
      }
      currentSection.questions.push(data);
    },
    removeQuestion(questionId) {
      const filtered =
        this.sections.filter(function(section){
          section.questions = section.questions.filter((question) => question.id !== questionId);
          return section
        });

      this.sections = filtered;
    },
    updateScenarioQuestions(data) {
      let scenarioIndex = 0;
      let sectionIndex = 0;

      this.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      const currentSection = this.sections[sectionIndex];

      currentSection.scenarios.forEach((s, i) => {
        if (s.id === data.cbe_scenario_id) {
          scenarioIndex = i;
        }
      });
      const currentScenario = currentSection.scenarios[scenarioIndex];
      if (!('questions' in currentScenario)) {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentScenario, 'questions', []);
      }
      currentScenario.questions.push(data);
    },
    removeScenarioQuestion(questionId) {
      const filtered =
        this.sections.filter(function(section){
          section.scenarios.filter(function(scenario){
            scenario.questions = scenario.questions.filter((question) => question.id !== data);
            return scenario
          });
          return section
        });

      this.sections = filtered;
    },
    sortingOrderValue(object) {
      let order = 1;
      if ( object ) order = object.length + 1;

      return order;
    },
    sectionSortingOrderValue(section){
      const totalQuestions = section.scenarios.reduce(this.totalQuestions, 0);
      return totalQuestions + 1;
    },
    totalQuestions(sum, scenario){
      let totalQuestions = 0
      if(scenario.questions){
        totalQuestions = scenario.questions.length;
      } else {
        totalQuestions = 0
      }

      return totalQuestions + sum;
    }
  },
};
</script>
