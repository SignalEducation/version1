<template>
    <div>
        <div class="form-group row">


            <div v-if="isLoaded">
                <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm"></label>
                <div class="col-md-10">                
                <select  :value="this.$store.selectedQuestionType" class="form-control form-control-sm" @change="onChange($event)" >         
                <option class="col-md-8" v-for="option in this.$store.questionTypes" v-bind:value="option.name">
                    {{option.name}}
                </option>   
                </select>
                    
                {{this.$store.selectedQuestionType}}
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

    computed: {
        selectedSearchType: {
            get() { 
                return  this.$store.selectedQuestionType//value from store 
            },
            selectedSearchType(val) {
                console.log("**** Set VAL *** ")
                this.$store.commit('selectedSearchType', val)
            },
        }

  },

    methods: {
            fetchQuestionTypes: function (page, index) {
                axios.get('http://localhost:3000/api/cbe_question_types/')
                    .then(response => {
                        this.$store.questionTypes = response.data
                        this.isLoaded = true
                    })
                    .catch(e => {
                        console.log('Error' + e)
                    })

            },
            onChange(event) {
                this.$store.commit('setCurrentQuestionType', event.target.value)
                console.log(event.target.value)
                console.log(this.$store.state.currentQuestionType)
            }
    }

}
</script>

<style>

</style>
