<template>
    <div class="form-group row">
        <label for="colFormLabelSm" class="col-sm-2 col-form-label col-form-label-sm">Subject</label>
        <div class="col-md-10">
            <select  v-model="selectedSubject" class="form-control form-control-sm">         
                <option class="col-md-8" v-for="option in options" v-bind:value="option.id">
                    {{option.name}}
                </option>   
            </select>
        </div>
    </div>
</template>


<script>
    import axios from 'axios'

    export default {
        mounted(){
            this.showSubjects()
        },
        data: function () {
            return {
                selectedSubject: null,
                options: []
            }
        },
        methods: {
            showSubjects: function (page, index) {
                console.log('TEST 1')
                axios.get('http://localhost:3000/api/subjects')
                    .then(response => {
                        console.log('** Subjects loaded')
                        this.options = response.data
                        console.log(this.subjects)
                    })
                    .catch(e => {
                        console.log('Error')
                    })

            },
        }
    }
</script>


<style scoped>
    p {
        font-size: 2em;
        text-align: center;
    }
</style>
