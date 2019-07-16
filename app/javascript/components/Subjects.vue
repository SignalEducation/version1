<template>           
    <select v-model="selectedSubject">
        <option>Choose Option</option>
        <option v-for="option in options" v-bind:value="option.id">
         {{option.name}}
        </option>
    </select>      
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
                axios.get('http://localhost:3000/cbes/1/get_subjects/')
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
