<template>

    <main>
        <article class="bg-gray5">
            <div class="container">

                <section class="pb-md-6 pb-5">
                    <div id="">

                        <span><p>CBE DB Index >> {{createdCBE.cbeId}} --- New CBE Name: {{createdCBE.cbeName}} ---  {{selectedSubject}}</p></span>
                        <div>
                            <button v-on:click="showSubjects">Show Subjects</button>

                            <select v-model="selectedSubject">
                                <option>Choose Option</option>
                                <option v-for="option in options" v-bind:value="option.id">
                                    {{option.name}}
                                </option>
                            </select>
                            {{selected}}
                            <br/><br/><br/>
                            <button v-on:click="createCBE">Create CBE</button>
                            <input v-model="cbeName" placeholder="CBE Name">
                            <br/><br/><br/>
                            <button v-on:click="createSection">Create Section</button>
                            <input v-model="sectionName" placeholder="Section Name">


                        </div>

                        <div>


                        </div>

                    </div>
                </section>
            </div>
        </article>
    </main>

</template>

<script>
    import axios from 'axios'
    import Admin from './components/Admin'
    import Exam from './components/Exam'


    export default {
        el: 'vueapp',
        components: {
            'admin': Admin,
            'exam': Exam,
        },
        data: function () {
            return {
                createdCBE: [],
                selectedSubject: "Subject",
                message: 'Test',
                options: []
            }


        },
        methods: {
            showSubjects: function (page, index) {
                console.log('TEST 1')
                axios.get('http://localhost:3000/cbes/1/get_subjects/')
                    .then(response => {
                        this.options = response.data
                        console.log(this.subjects)
                    })
                    .catch(e => {
                        console.log('Error')
                    })

            },
            createCBE: function (page, index) {
                console.log('cbeName: ' + this.cbeName)
                axios.post('http://localhost:3000/cbes/1/create_it', {
                    cbe_name: this.cbeName,
                    selected_subject: this.selectedSubject
                })
                    .then(response => {
                        console.log(response.status)
                        console.log(response.data)
                        this.createdCBE = response.data
                        console.log(this.createdCBE.cbeId)
                    })
                    .catch(error => {
                        console.log(error)
                    })
            },
            createSection: function (page, index) {
                console.log('cbeName: ' + this.cbeName)
                axios.post('http://localhost:3000/cbes/1/create_it', {cbe_id: this.createdCBE.cbeId})
                    .then(response => {
                        console.log(response.status)
                    })
                    .catch(error => {
                        console.log(error)
                    })
            }

        },

    }
</script>


<style scoped>
    p {
        font-size: 2em;
        text-align: center;
    }
</style>
