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
              @click="toggleCbeDetails"
              variant="primary"
            >
              <span class="when-opened">&#10514;</span>
              <span class="when-closed">&#10515;</span> CBE Details
            </b-button>
            <b-button
              :class="shouldShowIntroPages ? 'collapsed mr-1' : 'mr-1'"
              :aria-expanded="shouldShowIntroPages ? 'true' : 'false'"
              aria-controls="collapse-intro-pages"
              @click="toggleIntroPages"
              variant="primary"
            >
              <span class="when-opened">&#10514;</span>
              <span class="when-closed">&#10515;</span> Intro Pages
            </b-button>
            <b-button
              :class="shouldShowResources ? 'collapsed mr-1' : 'mr-1'"
              :aria-expanded="shouldShowResources ? 'true' : 'false'"
              aria-controls="collapse-resources"
              @click="toggleResources"
              variant="primary"
            >
              <span class="when-opened">&#10514;</span>
              <span class="when-closed">&#10515;</span> Resources
            </b-button>
          </div>
        </div>
      </div>
    </div>

    <div>
      <b-collapse v-model="showCbeDetails" id="collapse-cbe" class="mb-2">
        <b-card>
          <Details></Details>
        </b-card>
      </b-collapse>
      <div v-if="this.$store.state.cbeDetailsSaved === true" class="mt-2">
        <b-collapse id="collapse-intro-pages" v-model="showIntroPages" class="mb-2">
          <b-card no-body>
            <b-tabs card>
              <IntroductionPage
                v-for="page in introPages"
                v-bind:key="'intro-page-tab-' + page.id"
                v-bind:id="page.id"
                v-bind:initialTitle="page.title"
                v-bind:initialKind="page.kind"
                v-bind:initialContent="page.content"
              ></IntroductionPage>
              <IntroductionPage v-on:add-introduction-page="updatePages"></IntroductionPage>
            </b-tabs>
          </b-card>
        </b-collapse>

        <b-collapse id="collapse-resources" v-model="showResources" class="mb-2">
          <Resources v-bind:resources="resources" v-on:add-resource="updateResources"></Resources>
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
                  <b-collapse v-bind:id="'section-edit-collapse-' + section.id" class="mt-2">
                    <b-card>
                      <Section
                        v-bind:id="section.id"
                        v-bind:initialName="section.name"
                        v-bind:initialScore="section.score"
                        v-bind:initialKind="section.kind"
                        v-bind:initialContent="section.content"
                      ></Section>
                    </b-card>
                  </b-collapse>
                  <b-card>
                    <p>Name: {{ section.name }} - Type: {{ section.kind }} - Score: {{ section.score }}</p>
                  </b-card>
                </div>
                <div class="col-sm-2">
                  <b-button
                    v-b-toggle="'section-edit-collapse-' + section.id"
                    variant="secondary"
                    class="mr-1"
                  >Edit Section</b-button>
                </div>
              </div>

              <hr />

              <div v-if="section.kind === 'objective'">
                <div v-for="(question) in section.questions" v-bind:key="question.id">
                  <b-card no-body class="mb-1">
                    <b-card-header header-tag="header" class="p-1" role="tab">
                      <b-button
                        block
                        href="#"
                        v-b-toggle="'accordion-' + question.id"
                        variant="secondary"
                      >Question - {{ question.id }}</b-button>
                    </b-card-header>

                    <b-collapse
                      v-bind:id="'accordion-'+ question.id"
                      accordion="my-accordion"
                      role="tabpanel"
                    >
                      <b-card-body>
                        <div class="row">
                          <div class="col-sm-12">
                            <Question
                              v-bind:section-id="section.id"
                              v-bind:id="question.id"
                              v-bind:initialContent="question.content"
                              v-bind:initialScore="question.score"
                              v-bind:initialKind="question.kind"
                              v-bind:initialAnswers="question.answers_attributes"
                            ></Question>
                          </div>
                        </div>
                      </b-card-body>
                    </b-collapse>
                  </b-card>
                </div>
                <b-card no-body class="mb-1">
                  <b-card-header header-tag="header" class="p-1" role="tab">
                    <b-button
                      block
                      href="#"
                      v-b-toggle.new-question-accordion
                      variant="primary"
                    >New Question</b-button>
                  </b-card-header>

                  <b-collapse
                    id="new-question-accordion"
                    visible
                    accordion="my-accordion"
                    role="tabpanel"
                  >
                    <b-card-body>
                      <Question v-bind:section-id="section.id" v-on:add-question="updateQuestions"></Question>
                    </b-card-body>
                  </b-collapse>
                </b-card>
              </div>

              <div v-else>
                <div class="row">
                  <div class="col-sm-12">
                    <b-card no-body>
                      <b-tabs pills card vertical nav-wrapper-class="w-5">
                        <b-tab
                          v-for="scenario in section.scenarios"
                          :key="'scenario-tab-' + scenario.id"
                          :title="'Scenario ' + scenario.id"
                        >
                          <b-card-text>
                            <div class="row">
                              <div class="col-sm-10">
                                <b-collapse
                                  v-bind:id="'scenario-edit-collapse-' + scenario.id"
                                  class="mt-2"
                                >
                                  <b-card>
                                    <Scenario
                                      v-bind:id="scenario.id"
                                      v-bind:initialContent="scenario.content"
                                    ></Scenario>
                                  </b-card>
                                </b-collapse>
                                <b-card>
                                  <p>Name: {{ scenario }}</p>
                                </b-card>
                              </div>
                              <div class="col-sm-2">
                                <b-button
                                  v-b-toggle="'scenario-edit-collapse-' + scenario.id"
                                  variant="secondary"
                                  class="mr-1"
                                >Edit Scenario</b-button>
                              </div>
                            </div>
                            <br />
                            <div v-for="question in scenario.questions" v-bind:key="question.id">
                              <b-card no-body class="mb-1">
                                <b-card-header header-tag="header" class="p-1" role="tab">
                                  <b-button
                                    block
                                    href="#"
                                    v-b-toggle="'accordion-' + question.id"
                                    variant="secondary"
                                  >Question - {{ question.id }}</b-button>
                                </b-card-header>

                                <b-collapse
                                  v-bind:id="'accordion-'+ question.id"
                                  accordion="question-accordion"
                                  role="tabpanel"
                                >
                                  <b-card-body>
                                    <div class="row">
                                      <div class="col-sm-12">
                                        <b-card>
                                          <Question
                                            v-bind:section-id="section.id"
                                            v-bind:scenario-id="scenario.id"
                                            v-bind:id="question.id"
                                            v-bind:initialContent="question.content"
                                            v-bind:initialScore="question.score"
                                            v-bind:initialKind="question.kind"
                                          ></Question>
                                        </b-card>
                                      </div>
                                    </div>
                                  </b-card-body>
                                </b-collapse>
                              </b-card>
                            </div>

                            <b-card no-body class="mb-1">
                              <b-card-header header-tag="header" class="p-1" role="tab">
                                <b-button
                                  block
                                  href="#"
                                  v-b-toggle.new-question-accordion
                                  variant="primary"
                                >New Question</b-button>
                              </b-card-header>

                              <b-collapse
                                id="new-question-accordion"
                                visible
                                accordion="my-accordion"
                                role="tabpanel"
                              >
                                <b-card-body>
                                  <Question
                                    v-bind:section-id="section.id"
                                    v-bind:scenario-id="scenario.id"
                                    v-on:add-question="updateScenarioQuestions"
                                  ></Question>
                                </b-card-body>
                              </b-collapse>
                            </b-card>
                          </b-card-text>
                        </b-tab>
                        <b-tab title="New Scenario">
                          <b-card-text>
                            <Scenario
                              v-bind:section-id="section.id"
                              v-on:add-scenario="updateScenarios"
                            ></Scenario>
                          </b-card-text>
                        </b-tab>
                      </b-tabs>
                    </b-card>
                  </div>
                </div>
              </div>
            </b-tab>
            <b-tab title="New Section">
              <Section v-on:add-section="updateSections"></Section>
            </b-tab>
          </b-tabs>
        </b-card>
      </div>
    </div>
  </div>
</template>

<script>
import Details from "./Details";
import Section from "./Section";
import IntroductionPage from "./IntroductionPage";
import Scenario from "./Scenario";
import Question from "./Question";
import Resources from "./Resources";

export default {
  components: {
    Details,
    IntroductionPage,
    Section,
    Scenario,
    Question,
    Resources
  },
  data() {
    return {
      cbeDetails: [],
      sections: [],
      introPages: [],
      resources: [],
      showIntroPages: false,
      showCbeDetails: true,
      showResources: false
    };
  },
  computed: {
    shouldShowCbeDetails: function() {
      return (
        this.showCbeDetails && !(this.showIntroPages || this.showResources)
      );
    },
    shouldShowIntroPages: function() {
      return (
        this.showIntroPages && !(this.showCbeDetails || this.showResources)
      );
    },
    shouldShowResources: function() {
      return (
        this.showResources && !(this.showCbeDetails || this.showIntroPages)
      );
    }
  },
  methods: {
    toggleCbeDetails: function() {
      this.showCbeDetails = !this.showCbeDetails;
      if (this.showCbeDetails && (this.showIntroPages || this.showResources)) {
        this.showIntroPages = false;
        this.showResources = false;
      }
    },
    toggleIntroPages: function() {
      this.showIntroPages = !this.showIntroPages;
      if (this.showIntroPages && (this.showCbeDetails || this.showResources)) {
        this.showCbeDetails = false;
        this.showResources = false;
      }
    },
    toggleResources: function() {
      this.showResources = !this.showResources;
      if (this.showResources && (this.showCbeDetails || this.showIntroPages)) {
        this.showCbeDetails = false;
        this.showIntroPages = false;
      }
    },
    updateSections: function(data) {
      this.sections.push(data);
    },
    updatePages: function(data) {
      this.introPages.push(data);
    },
    updateResources: function(data) {
      this.resources.push(data);
    },
    updateScenarios: function(data) {
      let sectionIndex = 0;
      this.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      let currentSection = this.sections[sectionIndex];
      if (currentSection.hasOwnProperty("scenarios")) {
        console.log(currentSection);
      } else {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentSection, "scenarios", []);
      }
      currentSection.scenarios.push(data);
    },
    updateQuestions(data) {
      let sectionIndex = 0;
      this.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      let currentSection = this.sections[sectionIndex];
      if (currentSection.hasOwnProperty("questions")) {
        console.log(currentSection);
      } else {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentSection, "questions", []);
      }
      currentSection.questions.push(data);
    },
    updateScenarioQuestions(data) {
      let scenarioIndex = 0;
      let sectionIndex = 0;

      this.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      let currentSection = this.sections[sectionIndex];

      currentSection.scenarios.forEach((s, i) => {
        if (s.id === data.cbe_scenario_id) {
          scenarioIndex = i;
        }
      });
      let currentScenario = currentSection.scenarios[scenarioIndex];
      if (currentScenario.hasOwnProperty("questions")) {
        console.log(currentScenario);
      } else {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentScenario, "questions", []);
      }
      currentScenario.questions.push(data);
    }
  }
};
</script>
