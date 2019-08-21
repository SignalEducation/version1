<template>


  <section>
    <h1>CBE Details</h1>
    <p> {{ this.cbes.name }}</p>
    <div role="tablist">
    <div v-for="cbe_section in this.cbes.cbe_sections">
      <b-card no-body class="mb-1">
        <b-card-header header-tag="header" class="p-1" role="tab">
          <b-button block href="#" v-b-toggle.accordion-1 variant="info">{{cbe_section.name }}</b-button>
        </b-card-header>
        <b-collapse id="accordion-1" visible accordion="my-accordion" role="tabpanel">
          <b-card-body>
            <b-card-text>CBE Details</b-card-text>
            <b-card-text>{{ cbeQuestions[0].type }}</b-card-text>
          </b-card-body>
        </b-collapse>
      </b-card>
    </div>

    </div>
  </section>
  
</template>

<script>
  export default {
     data: function(){
       return {
          cbes: {
              "cbe_id": 1,
              "name": "ACCA CBE",
              "details": "Beginners Guide to Accountancy",
              "cbe_sections": [{
                  "id": 5,
                  "name": "Section A"
                }, {
                  "id": 6,
                  "name": "Section B"
                },
                {
                  "id": 7,
                  "name": "Section C"
                }
              ]
            },
	        cbeQuestions: [ 
            {"id": 5, "cbe_section": 5,"text": "40,000","type": "Multiple Choice","correctAnswer": true},
            {"id": 6, "cbe_section": 5,"text": "15,000","type": "Multiple Choice","correctAnswer": false},
            {"id": 7, "cbe_section": 5,"text": "1,000","type": "Multiple Choice","correctAnswer": false},
            {"id": 8, "cbe_section": 5,"text": "4,000","type": "Multiple Choice","correctAnswer": false} 
          ]
        }
      }
    }


</script>
