<template>
    <div class="row">
        <div class="col-sm-10">
            <div class="form-group">
                <label for="colFormLabelSm">Subject</label>
                <div class="input-group input-group-lg">
                    <select  v-model="selectedSubject" class="form-control custom-select">
                        <option class="col-md-8" v-for="option in options" v-bind:value="option.id">
                            {{option.name}}
                        </option>
                    </select>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import axios from 'axios'

    export default {
        mounted(){
            this.showSubjects()
            this.fetchQuestionTypes()
            this.fetchQuestionStatuses()
            // TODO this.fetchSectionTypes()
        },
        data: function () {
            return {
                selectedSubject: null,
                options: []
            }
        },
        methods: {
            showSubjects: function (page, index) {
                axios.get('http://localhost:3000/api/subjects/')
                    .then(response => {
                        this.options = response.data
                    })
                    .catch(e => {
                        console.log('Error')
                    })

            },
            fetchQuestionTypes: function (page, index) {
                axios.get('http://localhost:3000/api/cbe_question_types/')
                    .then(response => {
                        this.$store.questionTypes = response.data
                        return response.data
                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            },
            fetchQuestionStatuses: function (page, index) {
                axios.get('http://localhost:3000/api/cbe_question_statuses/')
                    .then(response => {
                        this.$store.questionStatuses = response.data
                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            },
            fetchSectionTypes: function (page, index) {
                axios.get('http://localhost:3000/api/v1/cbe_section_types/')
                    .then(response => {
                        this.$store.SectionTypes = response.data

                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            }
           
        }
    }
</script>


<style scoped>
    p {
        font-size: 2em;
        text-align: center;
    }
</style>
