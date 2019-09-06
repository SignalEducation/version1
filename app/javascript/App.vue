<template>
  <div class="panel-body no-top-padding">
    <div>
      <div class="row">
        <div class="col-sm-12 mb-2">
          <div v-if="this.$store.state.cbeDetailsSaved === true">
            <b-button v-b-toggle.collapse-cbe variant="primary" class="mr-1">
              <span class="when-opened">&#10514;</span> <span class="when-closed">&#10515;</span> CBE Details
            </b-button>
            <b-button variant="primary" class="mr-1">
              Intro Pages
            </b-button>
            <b-button variant="primary" class="mr-1">
              Resources
            </b-button>
          </div>
        </div>
      </div>
    </div>

    <div>
      <b-collapse visible id="collapse-cbe" class="mb-2">
        <b-card>
          <CBEDetails></CBEDetails>
        </b-card>
      </b-collapse>
      <div v-if="this.$store.state.cbeDetailsSaved === true" class="mt-2">
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
    import CBEDetails from "./components/CBEDetails";
    import CBESection from "./components/CBESection";
    import CBEScenario from "./components/CBEScenario";
    import CBEQuestion from "./components/CBEQuestion";

    export default {
      components: {
        CBEDetails,
        CBESection,
        CBEScenario,
        CBEQuestion
      },
      data: function() {
        return {
            cbeDetails: [],
            sections: [],
        };
      },
      methods: {
        updateSections: function(data) {
            this.sections.push(data);
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
        updateQuestions: function(data) {
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
        updateScenarioQuestions: function(data) {
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
        }

      }
    };
</script>
