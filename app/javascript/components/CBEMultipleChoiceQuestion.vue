<template>
    <div>
        <div class="form-group row">


            <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Multiple Choice Question</label>
            <div class="col-md-10">
                <input class="col-md-12" v-model="questionName" placeholder="Question Name">
                <input class="col-md-12" v-model="questionDescription" placeholder="Question Description">
                <input class="col-md-12" v-model="correctAnswer" placeholder="Correct Answer">
            
            
            <button @click="showChoices = true">Edit Multiple Question Choices</button>
            
            <div v-if="this.$store.state.selectedSelectQuestion === 'Multiple Choice'">
                {{selectedSelectQuestion}}
                <input class="col-md-12" v-model="choiceOne" placeholder="Choice 1">
                <input class="col-md-12" v-model="choice2" placeholder="Choice 2">
                <input class="col-md-12" v-model="choice3" placeholder="Choice 3">
                <input class="col-md-12" v-model="choice4" placeholder="Choice 4">
            </div>



                
            </div>
        </div>
    </div>
</template>

<script>
export default {
 data: function () {
        return {
            questionDetails: {},
            questionName: null,
            questionDescription: null,
            correctAnswer: null,
            selectedSelectQuestion: null,
            showChoices: false,

        }},
        methods: {
            addSection: function (page, index) {
                console.log("&1")
                this.questionDetails['name'] = this.sectionName
                this.questionDetails['scenario_label'] = this.sectionLabel
                this.questionDetails['scenario_description'] = this.sectionDescription
                this.questionDetails['cbe_id'] = this.$store.state.currentCbeId
                console.log("fadfasdfdas")
                console.log(JSON.stringify(this.sectionDetails))
                axios.post('http://localhost:3000/cbes/1/create_section', {cbe_section: this.sectionDetails})
                    .then(response => {
                        console.log(response.status)
                       
                        this.createdSection = response.data
                        console.log(JSON.stringify(response.data))
                        console.log("******** " + JSON.stringify(this.createdSection))
                        /* his.$store.commit('setCurrentCbeId', this.createdCBE.cbeId)
                        console.log(" From store ******** " + this.createdCBE.cbeId )
                        */
                       
                    })
                    .catch(error => {
                        console.log(error)
                    })
        },
}

}
</script>

<style>

</style>
