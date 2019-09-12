<template>
  <div class="panel-body no-top-padding">
    <div>
      <div class="row">
        <div class="col-sm-12 mb-2">
          <div v-if="this.$store.state.cbeDetailsSaved === true">
            <b-button :class="shouldShowCbeDetails ? 'collapsed mr-1' : 'mr-1'"
                      :aria-expanded="shouldShowCbeDetails ? 'true' : 'false'"
                      aria-controls="collapse-cbe"
                      @click="toggleCbeDetails"
                      variant="primary">
              <span class="when-opened">&#10514;</span> <span class="when-closed">&#10515;</span> CBE Details
            </b-button>
            <b-button :class="shouldShowIntroPages ? 'collapsed mr-1' : 'mr-1'"
                      :aria-expanded="shouldShowIntroPages ? 'true' : 'false'"
                      aria-controls="collapse-intro-pages"
                      @click="toggleIntroPages"
                      variant="primary">
              <span class="when-opened">&#10514;</span> <span class="when-closed">&#10515;</span> Intro Pages
            </b-button>
            <b-button variant="primary" class="mr-1">
              Resources
            </b-button>
          </div>
        </div>
      </div>
    </div>

    <div>
      <b-collapse v-model="showCbeDetails" id="collapse-cbe" class="mb-2">
        <b-card>
          <CBEDetails></CBEDetails>
        </b-card>
      </b-collapse>
      <div v-if="this.$store.state.cbeDetailsSaved === true" class="mt-2">
        <b-collapse id="collapse-intro-pages" v-model="showIntroPages" class="mb-2">
          <b-card no-body>
            <b-tabs card >
              <CBEIntroductionPage
                v-for="page in introPages"
                v-bind:key="'intro-page-tab-' + page.id"
                v-bind:id="page.id"
                v-bind:initialTitle="page.title"
                v-bind:initialKind="page.kind"
                v-bind:initialContent="page.content"
                ></CBEIntroductionPage>
              <CBEIntroductionPage v-on:add-introduction-page="updatePages"></CBEIntroductionPage>
            </b-tabs>
          </b-card>
        </b-collapse>

        <b-card no-body>
          <b-tabs card >
            <b-tab v-for="section in sections" :key="'section-tab-' + section.id" :title="section.name">
              <div class="row">
                <div class="col-sm-10">
                  <b-card>
                    <b-card-text>{{ section.name }}</b-card-text>
                  </b-card>
                </div>
                <div class="col-sm-2">
                  <b-button variant="secondary" class="mr-1">Edit Section</b-button>
                </div>
              </div>

              <hr/>

              <div v-if="section.kind === 'objective'">
                <div v-for="(question, index) in section.questions">
                  <b-card no-body class="mb-1">
                    <b-card-header header-tag="header" class="p-1" role="tab">
                      <b-button block href="#" v-b-toggle="'accordion-' + question.id" variant="secondary">Question - {{ question.id }}</b-button>
                    </b-card-header>

                    <b-collapse v-bind:id="'accordion-'+ question.id" accordion="my-accordion" role="tabpanel">
                      <b-card-body>
                        <div class="row">
                          <div class="col-sm-10">
                            <b-card-text>{{ question }}</b-card-text>
                          </div>
                          <div class="col-sm-2">
                            <b-button variant="secondary" class="mr-1">Edit Question</b-button>
                          </div>
                        </div>
                      </b-card-body>
                    </b-collapse>
                  </b-card>
                </div>
                <b-card no-body class="mb-1">
                  <b-card-header header-tag="header" class="p-1" role="tab">
                    <b-button block href="#" v-b-toggle.new-question-accordion variant="primary">New Question</b-button>
                  </b-card-header>

                  <b-collapse id="new-question-accordion" visible accordion="my-accordion" role="tabpanel">
                    <b-card-body>
                      <CBEQuestion v-bind:section-id="section.id" v-on:add-question="updateQuestions"></CBEQuestion>
                    </b-card-body>
                  </b-collapse>
                </b-card>
              </div>

              <div v-else>
                <div class="row">
                  <div class="col-sm-12">
                    <b-card no-body>
                      <b-tabs pills card vertical nav-wrapper-class="w-5">
                        <b-tab v-for="scenario in section.scenarios" :key="'scenario-tab-' + scenario.id" :title="'Scenario ' + scenario.id" >
                          <b-card-text>
                            <div class="row">
                              <div class="col-sm-10">
                                <b-card>
                                  <b-card-text>{{ scenario.content }}</b-card-text>
                                </b-card>
                              </div>
                              <div class="col-sm-2">
                                <b-button variant="secondary" class="mr-1">Edit Scenario</b-button>
                              </div>
                            </div>
                            <br/>
                            <div v-for="question in scenario.questions">
                              <b-card no-body class="mb-1">
                                <b-card-header header-tag="header" class="p-1" role="tab">
                                  <b-button block href="#" v-b-toggle="'accordion-' + question.id" variant="secondary">Question - {{ question.id }}</b-button>
                                </b-card-header>

                                <b-collapse v-bind:id="'accordion-'+ question.id" accordion="question-accordion" role="tabpanel">
                                  <b-card-body>
                                    <div class="row">
                                      <div class="col-sm-10">
                                        <b-card-text>{{ question }}</b-card-text>
                                      </div>
                                      <div class="col-sm-2">
                                        <b-button variant="secondary" class="mr-1">Edit Question</b-button>
                                      </div>
                                    </div>
                                  </b-card-body>
                                </b-collapse>
                              </b-card>
                            </div>

                            <b-card no-body class="mb-1">
                              <b-card-header header-tag="header" class="p-1" role="tab">
                                <b-button block href="#" v-b-toggle.new-question-accordion variant="primary">New Question</b-button>
                              </b-card-header>

                              <b-collapse id="new-question-accordion" visible accordion="my-accordion" role="tabpanel">
                                <b-card-body>
                                  <CBEQuestion
                                      v-bind:section-id="section.id"
                                      v-bind:scenario-id="scenario.id"
                                      v-on:add-question="updateScenarioQuestions"
                                  ></CBEQuestion>
                                </b-card-body>
                              </b-collapse>
                            </b-card>
                          </b-card-text>
                        </b-tab>
                        <b-tab title="New Scenario">
                          <b-card-text>
                            <CBEScenario v-bind:section-id="section.id" v-on:add-scenario="updateScenarios"></CBEScenario>
                          </b-card-text>
                        </b-tab>
                      </b-tabs>
                    </b-card>
                  </div>
                </div>
              </div>
            </b-tab>
            <b-tab title="New Section">
              <CBESection v-on:add-section="updateSections"></CBESection>
            </b-tab>
          </b-tabs>
        </b-card>
      </div>
    </div>
  </div>
</template>

<script>
import CBEDetails          from "./components/CBEDetails";
import CBESection          from "./components/CBESection";
import CBEIntroductionPage from "./components/CBEIntroductionPage";
import CBEScenario         from "./components/CBEScenario";
import CBEQuestion         from "./components/CBEQuestion";

export default {
  components: {
    CBEDetails,
    CBEIntroductionPage,
    CBESection,
    CBEScenario,
    CBEQuestion,
  },
  data() {
    return {
        cbeDetails: [],
        sections: [],
        introPages: [],
        showIntroPages: false,
        showCbeDetails: true
    };
  },
  computed: {
    shouldShowCbeDetails: function () {
      return this.showCbeDetails && !this.showIntroPages;
    },
    shouldShowIntroPages: function () {
      return this.showIntroPages && !this.showCbeDetails;
    }
  },
  methods: {
    toggleCbeDetails: function() {
      this.showCbeDetails = !this.showCbeDetails;
      if (this.showIntroPages && this.showCbeDetails) {
        this.showIntroPages = false;
      }
    },
    toggleIntroPages: function() {
      this.showIntroPages = !this.showIntroPages;
      if (this.showIntroPages && this.showCbeDetails) {
        this.showCbeDetails = false;
      }
    },
    updateSections: function(data) {
        this.sections.push(data);
    },
    updatePages: function(data) {
        this.introPages.push(data);
    },
    updateScenarios: function(data) {
        let sectionIndex = 0;
        this.sections.forEach((s, i) => {
            if (s.id === data.cbe_section_id) {
                sectionIndex =  i;
            }
        });
        let currentSection = this.sections[sectionIndex];
        if (currentSection.hasOwnProperty('scenarios')) {
            console.log(currentSection);
        } else {
            // This $set syntax is required by Vue to ensure the section.questions array is reactive
            // It is inside the conditional to ensure section.questions is not reset to empty
            this.$set(currentSection, 'scenarios', []);
        }
        currentSection.scenarios.push(data);
    },
    updateQuestions(data) {
        let sectionIndex = 0;
        this.sections.forEach((s, i) => {
            if (s.id === data.cbe_section_id) {
                sectionIndex =  i;
            }
        });
        let currentSection = this.sections[sectionIndex];
        if (currentSection.hasOwnProperty('questions')) {
            console.log(currentSection);
        } else {
            // This $set syntax is required by Vue to ensure the section.questions array is reactive
            // It is inside the conditional to ensure section.questions is not reset to empty
            this.$set(currentSection, 'questions', []);
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
                scenarioIndex =  i;
            }
        });
        let currentScenario = currentSection.scenarios[scenarioIndex];
        if (currentScenario.hasOwnProperty('questions')) {
            console.log(currentScenario);
        } else {
            // This $set syntax is required by Vue to ensure the section.questions array is reactive
            // It is inside the conditional to ensure section.questions is not reset to empty
            this.$set(currentScenario, 'questions', []);
        }
        currentScenario.questions.push(data);
    },

  },
};
</script>
