<template>
    <div>
        <div class="form-group row">
            <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Section Title</label>
            <div class="col-md-10">
                <input class="col-md-12" v-model="sectionName" placeholder="Section Name">
                <input class="col-md-12" v-model="sectionDescription" placeholder="Section Description">
                <input class="col-md-12" v-model="sectionLabel" placeholder="Section Label">
                <button v-on:click="addSection">Add Section</button>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data: function () {
        return {
            sectionName: null,
            sectionLabel: null,
            sectionDescription: null,
        }},
        methods: {
            addSection: function (page, index) {
        },
}

}
</script>

<style>

</style>
