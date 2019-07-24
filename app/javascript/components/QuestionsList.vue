<template>
    <div>
        <div class="form-group row">


            <div v-if="isLoaded">
                <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm"></label>
                <div class="col-md-10">
                <select  v-model="this.$store.selectedSelectQuestion" class="form-control form-control-sm">         
                <option class="col-md-8" v-for="option in this.$store.questionTypes" v-bind:value="option.name">
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
    data: function () {
            return {
            isLoaded: false
        }
    },
    mounted() {
        this.fetchQuestionTypes()
    },

    methods: {

            fetchQuestionTypes: function (page, index) {
                console.log('Question Types >>')
                axios.get('http://localhost:3000/cbes/1/question_types/')
                    .then(response => {
                        console.log("**** Question Types")
                        console.log(response)
                        console.log(response.data)
                        console.log("**** Question Types")
                        this.$store.questionTypes = response.data
                        this.isLoaded = true

                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            }
    }

}
</script>

<style>

</style>
