<template>
    <div>
        <div class="form-group row">
            <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Section Title</label>
            <div class="col-md-10">
                <input class="col-md-12" v-model="cbeSection" placeholder="Section Title">
            </div>
        </div>
    </div>
</template>

<script>
export default {
            data: function () {
            return {
                cbeSection: null
            }
        }
}
</script>

<style>

</style>
