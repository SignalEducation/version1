<template>
    <div>
        <div class="form-group row">
            <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Section Title</label>
            <div class="col-md-10">
                <input class="col-md-12" v-model="sectionName" placeholder="Section Name">
                <input class="col-md-12" v-model="sectionDescription" placeholder="Section Description">
                <input class="col-md-12" v-model="sectionLabel" placeholder="Section Label">
                
            </div>

            <div>
                <div>
                    <button v-on:click="saveSection">Save Section</button>
                      <div v-show="this.$emit.showQuestions">
                          <span class="badge badge-pill badge-primary">Section ID {{this.$store.state.currentSectionId}}</span>
                       </div>
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
            sectionDetails: {},
            sectionName: null,
            sectionLabel: null,
            sectionDescription: null,
            createdSection: null
        }},
        props: ['showQuestions'],
        methods: {
            saveSection: function (page, index) {
                this.sectionDetails['name'] = this.sectionName
                this.sectionDetails['scenario_label'] = this.sectionLabel
                this.sectionDetails['scenario_description'] = this.sectionDescription
                this.sectionDetails['cbe_id'] = this.$store.state.currentCbeId
                axios.post('http://localhost:3000/api/cbes/' + this.$store.state.currentCbeId + '/cbe_sections', {cbe_section: this.sectionDetails})
                    .then(response => {
                     this.createdSection = response.data       
                        this.$store.commit('setCurrentSectionId', this.createdSection.cbeSectionId)
                        if (this.$store.state.currentSectionId > 0 ) {
                            this.$store.state.showQuestions = true
                            this.$store.state.showSections = false
                        }
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
