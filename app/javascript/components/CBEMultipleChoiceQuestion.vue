<template>
    <div>
        <div class="form-group">
            <label for="colFormLabelSm" >Question Name</label>
            <div class="input-group input-group-lg">
                <input v-model="questionName" placeholder="Question Name" class="form-control">
            </div>
        </div>
        <div class="form-group">
            <label for="colFormLabelSm" >Question Description</label>
            <div class="input-group input-group-lg">
                <input v-model="questionDescription" placeholder="Question Description" class="form-control">
            </div>
        </div>
        <div class="form-group">
            <label for="colFormLabelSm" >Correct Answer</label>
            <div class="input-group input-group-lg">
                <input v-model="correctAnswer" placeholder="Correct Answer" class="form-control">
            </div>
        </div>

        <button @click="showChoices = true" class='btn btn-primary'>Edit Multiple Question Choices</button>
            
        <div v-if="this.$store.state.selectedSelectQuestion === 'Multiple Choice'">
            {{selectedSelectQuestion}}
            <input class="col-md-12" v-model="choiceOne" placeholder="Choice 1">
            <input class="col-md-12" v-model="choice2" placeholder="Choice 2">
            <input class="col-md-12" v-model="choice3" placeholder="Choice 3">
            <input class="col-md-12" v-model="choice4" placeholder="Choice 4">
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
                this.questionDetails['name'] = this.sectionName
                this.questionDetails['scenario_label'] = this.sectionLabel
                this.questionDetails['scenario_description'] = this.sectionDescription
                this.questionDetails['cbe_id'] = this.$store.state.currentCbeId
                
                axios.post('http://localhost:3000/api/cbes/' + this.$store.state.currentCbeId + 'create_section', {cbe_section: this.sectionDetails})
                    .then(response => {
                      this.createdSection = response.data
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
