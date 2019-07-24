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
                    <button v-on:click="saveSection">Save</button>
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
        methods: {
            saveSection: function (page, index) {
                console.log("&1")
                this.sectionDetails['name'] = this.sectionName
                this.sectionDetails['scenario_label'] = this.sectionLabel
                this.sectionDetails['scenario_description'] = this.sectionDescription
                this.sectionDetails['cbe_id'] = this.$store.state.currentCbeId
                console.log("Section -- CBE ID -- " +  JSON.stringify(this.$store.state.currentCbeId))
                console.log(JSON.stringify(this.sectionDetails))
                axios.post('http://localhost:3000/cbes/1/create_section', {cbe_section: this.sectionDetails})
                    .then(response => {
                        console.log(response.status)
                       
                        this.createdSection = response.data
                        console.log("******** ")
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
