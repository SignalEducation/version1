<template>
    <div class="panel-body no-top-padding">

        <div>
            <div v-if="this.$store.state.cbeDetailsSaved === true" class="mb-2">
                <b-button v-b-toggle.collapse-cbe variant="primary">
                    <span class="when-opened">Close</span> <span class="when-closed">Open</span> CBE Details
                </b-button>
            </div>

            <b-collapse visible id="collapse-cbe" class="mb-2">
                <b-card>
                    <CBEDetails></CBEDetails>
                </b-card>
            </b-collapse>
        </div>


        <div v-if="this.$store.state.cbeDetailsSaved === true" role="tablist" class="pt-5">
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



        <!-- Add Section
            <div v-if="cbeSectionButton === true" class="mt-4">
                <button v-on:click="makeCBESectionVisible" class="btn btn-secondary">Add Section</button>
            </div>
        -->


  </div>
</template>

<script>
    import CBEDetails from "./components/CBEDetails";
    import CBESection from "./components/CBESection";
    import CBEQuestion from "./components/CBEQuestion";

    export default {
      components: {
        CBEDetails,
        CBESection,
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
        }

      }
    };
</script>
