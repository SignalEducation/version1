<template>
  <div class="panel-body no-top-padding">
    <div>
      <div class="row">
        <div class="col-sm-12 mb-2">
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

    <div>
      <b-collapse id="collapse-cbe" v-model="showCbeDetails" class="mb-2">
        <b-card>
          <Details
            :id="edit_cbe_data.id"
            :initialName="edit_cbe_data.name"
            :initialCourseId="edit_cbe_data.subject_course.id"
            :initialAgreementContent="edit_cbe_data.agreement_content"
            :initialExamTime="edit_cbe_data.exam_time"
            :initialActive="edit_cbe_data.active"
          />
        </b-card>
      </b-collapse>

      <b-collapse
        id="collapse-intro-pages"
        v-model="showIntroPages"
        class="mb-2"
      >
        <b-card no-body>
          <b-tabs card>
            <IntroductionPage
              v-for="page in edit_cbe_data.introduction_pages"
              :id="page.id"
              :key="'intro-page-tab-' + page.id"
              :initialTitle="page.title"
              :initialKind="page.kind"
              :initialContent="page.content"
            />
            <IntroductionPage @add-introduction-page="updatePages" />
          </b-tabs>
        </b-card>
      </b-collapse>

      <b-collapse
        id="collapse-resources"
        v-model="showResources"
        class="mb-2"
      >
        <Resources
          :resources="edit_cbe_data.resources"
          @add-resource="updateResources"
        />
      </b-collapse>

      <h3>Exam Content</h3>
      <b-card no-body>
        <b-tabs card>
          <b-tab
            v-for="section in edit_cbe_data.sections"
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
                      :id="section.id"
                      :initialName="section.name"
                      :initialScore="section.score"
                      :initialKind="section.kind"
                      :initialContent="section.content"
                    />
                  </b-card>
                </b-collapse>
                <b-card>
                  <p>
                    Name: {{ section.name }} - Type: {{ section.kind }} - Score: {{ section.score }}
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
                    class="p-1" role="tab"
                  >
                    <b-button
                      v-b-toggle="'accordion-' + question.id"
                      block
                      href="#"
                      variant="secondary"
                    >
                      Question - {{ question.id }}
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
                            :initialContent="question.content"
                            :initialScore="question.score"
                            :initialKind="question.kind"
                            :initialAnswers="question.answers"
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
                                    :initialName="scenario.name"
                                    :initialContent="scenario.content"
                                  />
                                </b-card>
                              </b-collapse>
                              <b-card>
                                <p>Name: {{ scenario.name }}</p>
                              </b-card>
                            </div>
                            <div class="col-sm-2">
                              <b-button
                                v-b-toggle="'scenario-edit-collapse-' + scenario.id"
                                variant="secondary"
                                class="mr-1"
                              >
                                Edit Scenario
                              </b-button>
                            </div>
                          </div>
                          <br >
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
                                  Question - {{ question.id }}
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
                                          :scenario-id="scenario.id"
                                          :initialContent="question.content"
                                          :initialScore="question.score"
                                          :initialKind="question.kind"
                                          :initialAnswers="question.answers"
                                        />
                                      </b-card>
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
                                  :scenario-id="scenario.id"
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
            <Section @add-section="updateSections" />
          </b-tab>
        </b-tabs>
      </b-card>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Details from './Details.vue';
import Section from './Section.vue';
import IntroductionPage from './IntroductionPage.vue';
import Scenario from './Scenario.vue';
import Question from './Question.vue';
import Resources from './Resources.vue';

export default {
  components: {
    Details,
    IntroductionPage,
    Section,
    Scenario,
    Question,
    Resources,
  },
  data() {
    return {
      cbeId: null,
      showIntroPages: false,
      showCbeDetails: false,
      showResources: false,
    };
  },
  computed: {
    ...mapGetters('cbe', {
      edit_cbe_data: 'edit_cbe_data',
    }),
    shouldShowCbeDetails() {
      return this.showCbeDetails && !(this.showIntroPages || this.showResources);
    },
    shouldShowIntroPages() {
      return this.showIntroPages && !(this.showCbeDetails || this.showResources);
    },
    shouldShowResources() {
      return this.showResources && !(this.showCbeDetails || this.showIntroPages);
    },
  },
  mounted() {
    this.getCBEId();
  },
  methods: {
    getCBEId() {
      const url = document.URL;
      this.url_cbe_id = url.substr(url.lastIndexOf('/') + 1);
      this.cbeId = parseInt(this.url_cbe_id, 10);
      this.$store.commit('setCbeId', this.cbeId);
      this.$store.dispatch('cbe/getEditCbe', this.cbeId);
    },
    toggleCbeDetails: () => {
      this.showCbeDetails = !this.showCbeDetails;
      if (this.showCbeDetails && (this.showIntroPages || this.showResources)) {
        this.showIntroPages = false;
        this.showResources = false;
      }
    },
    toggleIntroPages: () => {
      this.showIntroPages = !this.showIntroPages;
      if (this.showIntroPages && (this.showCbeDetails || this.showResources)) {
        this.showCbeDetails = false;
        this.showResources = false;
      }
    },
    toggleResources: () => {
      this.showResources = !this.showResources;
      if (this.showResources && (this.showCbeDetails || this.showIntroPages)) {
        this.showCbeDetails = false;
        this.showIntroPages = false;
      }
    },
    updateSections: (data) => {
      this.edit_cbe_data.sections.push(data);
    },
    updatePages: (data) => {
      this.edit_cbe_data.introPages.push(data);
    },
    updateResources: (data) => {
      this.edit_cbe_data.resources.push(data);
    },
    updateScenarios: (data) => {
      let sectionIndex = 0;
      this.edit_cbe_data.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      const currentSection = this.edit_cbe_data.sections[sectionIndex];
      if (currentSection.hasOwnProperty('scenarios')) {
        console.log(currentSection);
      } else {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentSection, 'scenarios', []);
      }
      currentSection.scenarios.push(data);
    },
    updateQuestions: (data) => {
      let sectionIndex = 0;
      this.edit_cbe_data.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      const currentSection = this.edit_cbe_data.sections[sectionIndex];
      if (currentSection.hasOwnProperty('questions')) {
        console.log(currentSection);
      } else {
        // This $set syntax is required by Vue to ensure the section.questions array is reactive
        // It is inside the conditional to ensure section.questions is not reset to empty
        this.$set(currentSection, 'questions', []);
      }
      currentSection.questions.push(data);
    },
    updateScenarioQuestions: (data) => {
      let scenarioIndex = 0;
      let sectionIndex = 0;

      this.edit_cbe_data.sections.forEach((s, i) => {
        if (s.id === data.cbe_section_id) {
          sectionIndex = i;
        }
      });
      const currentSection = this.edit_cbe_data.sections[sectionIndex];

      currentSection.scenarios.forEach((s, i) => {
        if (s.id === data.cbe_scenario_id) {
          scenarioIndex = i;
        }
      });
      const currentScenario = currentSection.scenarios[scenarioIndex];
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
