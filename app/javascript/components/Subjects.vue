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
                console.log('TEST 1')
                axios.get('http://localhost:3000/cbes/1/get_subjects/')
                    .then(response => {
                        this.options = response.data
                    })
                    .catch(e => {
                        console.log('Error')
                    })

            },
            fetchQuestionTypes: function (page, index) {
                console.log('Question Types >>')
                axios.get('http://localhost:3000/cbes/1/question_types/')
                    .then(response => {
                        console.log("**** Question Types")
                        console.log(response)
                        console.log(response.data)
                        console.log("**** Question Types")
                        this.$store.questionTypes = response.data

                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            },
            fetchQuestionStatuses: function (page, index) {
                console.log('Question Types >>')
                axios.get('http://localhost:3000/cbes/1/question_statuses/')
                    .then(response => {
                        console.log("**** Question Statuses")
                        console.log(response)
                        console.log(response.data)
                        console.log("**** Question Statuses")
                        this.$store.questionStatuses = response.data

                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            },
            fetchSectionTypes: function (page, index) {
                console.log('Question Types >>')
                axios.get('http://localhost:3000/cbes/1/section_types/')
                    .then(response => {
                        console.log("**** Section Types")
                        console.log(response)
                        console.log(response.data)
                        console.log("**** Section Types")
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
