<template>
    <div class="panel-body no-top-padding">

        <div>
            <div v-if="cbeButton === true" class="mb-2">
                <b-button v-b-toggle.collapse-cbe variant="primary">
                    <span class="when-opened">Close</span> <span class="when-closed">Open</span> CBE Details
                </b-button>
            </div>
            <b-collapse visible id="collapse-cbe" class="mb-2">
                <b-card>
                    <div v-show="this.$store.state.showCBEDetails">
                        <CBEDetails></CBEDetails>
                    </div>
                    <!-- Save CBE -->
                    <button v-on:click="saveNewCBE" class="btn btn-primary">Save CBE</button>
                </b-card>
            </b-collapse>
        </div>


        <div v-if="cbeButton === true" role="tablist" class="pt-5">
            <div v-for="(section, index) in sections">
                <b-card no-body class="mb-1">
                    <b-card-header header-tag="header" class="p-1" role="tab">
                        <b-button block href="#" v-b-toggle="'accordion-' + index" variant="info">{{ section.name }}</b-button>
                    </b-card-header>

                    <b-collapse v-bind:id="'accordion-'+ index" accordion="my-accordion" role="tabpanel">
                        <b-card-body>
                            <b-card-text>{{ section.name }}</b-card-text>
                            <b-card-text>{{ section.score }}</b-card-text>
                            <b-card-text>{{ section.content }}</b-card-text>
                            <b-card-text>{{ section }}</b-card-text>


                            <div class="pt-5">
                                <!-- Section Questions List -->
                                <ul>
                                    <p>List of questions</p>
                                    <li v-for="question in section.questions">
                                        {{ question }}
                                    </li>
                                </ul>
                            </div>

                            <!-- Questions Component -->
                            <CBEQuestion v-bind:section-id="section.id" v-on:add-question="updateQuestions"></CBEQuestion>

                            <!-- Add Question -->
                            <div v-if="cbeQuestionButton === true" class="mt-4">
                                <button v-on:click="makeCBEQuestionVisible" class="btn btn-secondary">Add Question</button>
                            </div>


                            <button class="btn btn-secondary">Edit Section</button>
                        </b-card-body>
                    </b-collapse>
                </b-card>
            </div>

            <b-card no-body class="mb-1">
                <b-card-header header-tag="header" class="p-1" role="tab">
                    <b-button block href="#" v-b-toggle.new-accordion variant="info">New Section</b-button>
                </b-card-header>

                <b-collapse id="new-accordion" visible accordion="my-accordion" role="tabpanel">
                    <b-card-body>
                        <CBESection v-on:add-section="updateSections"></CBESection>
                    </b-card-body>
                </b-collapse>
            </b-card>

        </div>



        <!--
        <div class="form-group">
            <label for="colFormLabelSm">New Section</label>
            <div class="input-group input-group-lg">
                <input v-model="newSection" @keyup.enter="saveSection" placeholder="Section" class="form-control" />
            </div>
            <button class="btn btn-primary" @click="saveSection">Save Section</button>
        </div>


        <div v-show="this.$store.state.showSections">
            <CBESection></CBESection>
        </div>
        -->
        <!-- Add Section -->
        <div v-if="cbeSectionButton === true" class="mt-4">
            <button v-on:click="makeCBESectionVisible" class="btn btn-secondary">Add Section</button>
        </div>


        <!--

        <div v-show="this.$store.state.showQuestions">
          <button v-on:click="makeQuestionSelectionVisible" class="btn btn-secondary">Add Question</button>
        </div>

        <div v-show="showQuestionSelection">
          <QuestionsList></QuestionsList>
        </div>

        -->

  </div>
</template>

<script>
    import axios from "axios";
    import CBEDetails from "./components/CBEDetails";
    import CBESection from "./components/CBESection";
    import CBEQuestion from "./components/CBEQuestion";

    export default {
      components: {
        CBEDetails,
        CBESection,
        CBEQuestion
      },
      mounted() {
        this.makeCBEDetailsVisible();
      },

      data: function() {
        return {
          createdCBE: [],
          cbeQuestionValid: false,
          cbeDetails: [],
          showCBEDetails: false,
          showCBESection: false,
          showSubjects: true,
          cbeButton: false,
          cbeSectionButton: false,
          sections: [],
          sectionsCount: 0,
          sectionName: null,
          sectionScore: null,
          sectionKind: null,
          sectionContent: null,
          createdSection: null,
          showQuestionSelection: false,
          cbeQuestionButton: false,
        };
      },
      events: {
        eventShowCBESections: function(data) {
          this.makeCBESectionVisible;
        }
      },
      computed: {
        currentCBEId() {
          return this.$store.state.currentCbeId;
        }
      },
      methods: {
        makeCBEDetailsVisible: function(page, index) {
            this.$store.state.showCBEDetails = true;
            this.showCBEDetails = true;
        },
        makeCBESectionVisible: function(page, index) {
          this.$store.state.showSections = true;
          this.showCBESection = true;
        },
        updateSections: function(data) {
            this.sections.push(data);
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
        saveNewCBE: function(page, index) {
            this.cbeDetails = {};
            console.log(this.$store.state.cbeSubjectCourseId);
            this.cbeDetails["name"] = this.$store.state.cbeName;
            this.cbeDetails["agreement_content"] = this.$store.state.cbeAgreementContent;
            this.cbeDetails["exam_time"] = this.$store.state.cbeExamTime;
            this.cbeDetails["score"] = this.$store.state.cbeScore;
            this.cbeDetails["subject_course_id"] = this.$store.state.cbeSubjectCourseId;

            axios
                .post("http://localhost:3000/api/v1/cbes/", { cbe: this.cbeDetails })
                .then(response => {
                  console.log(response.status);
                  this.createdCBE = response.data;
                  this.$store.commit("setCurrentCbeId", this.createdCBE.id);
                  console.log(this.createdCBE.id);
                  console.log(this.$store.state.currentCbeId);
                  if (this.createdCBE.id > 0) {
                    this.cbeButton = true;
                  }
                })
                .catch(error => {
                  console.log(error);
                });
        },

      }
    };
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
