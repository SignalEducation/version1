<template>
    <div>
        <div class="form-group row">


            <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Multiple Choice Question</label>
            <div class="col-md-10">
            <select  v-model="this.$store.selectedSelectQuestion" class="form-control form-control-sm">         
            <option class="col-md-8" v-for="option in this.$store.questionTypes" v-bind:value="option.name">
                {{option.name}}
            </option>   
            </select>
            </div>
        </div>
    </div>
</template>

<script>
export default {

}
</script>

<style>

</style>
