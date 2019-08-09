<template>
    <div class="form-group row">
        <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Subject</label>
        <div class="col-md-10">
            <select  v-model="selectedSubject" class="form-control form-control-sm">         
                <option class="col-md-8" v-for="option in options" v-bind:value="option.id">
                    {{option.name}}
                </option>   
            </select>
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
            this.fetchSectionTypes()
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
                        this.$store.questionStatuses = response.datax
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
