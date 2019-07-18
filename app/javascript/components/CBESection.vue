<template>
    <div>
        <fieldset>
            <label for="">Section</label>
            <input v-model="cbeSection" placeholder="Create a new section">
        </fieldset>
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
