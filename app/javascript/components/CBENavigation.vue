<template>
  <div role="tablist">
    <b-card no-body class="mb-1">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button block href="#" v-b-toggle.accordion-1 variant="info">CBE</b-button>
      </b-card-header>
      <b-collapse id="accordion-1" visible accordion="my-accordion" role="tabpanel">
        <b-card-body>
          <b-card-text>CBE Details</b-card-text>
          <b-card-text>{{ text }}</b-card-text>
        </b-card-body>
      </b-collapse>
    </b-card>

    <b-card no-body class="mb-1">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button block href="#" v-b-toggle.accordion-2 variant="info">CBE Sections</b-button>
      </b-card-header>
      <b-collapse id="accordion-2" accordion="my-accordion" role="tabpanel">
        <b-card-body>
          <b-card-text>{{ text }}</b-card-text>
        </b-card-body>
      </b-collapse>
    </b-card>

    <b-card no-body class="mb-1">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button block href="#" v-b-toggle.accordion-3 variant="info">Questions</b-button>
      </b-card-header>
      <b-collapse id="accordion-3" accordion="my-accordion" role="tabpanel">
        <b-card-body>
          <b-card-text>{{ text }}</b-card-text>
        </b-card-body>
      </b-collapse>
    </b-card>
  </div>
</template>

<script>

  export default {
     data: function(){
            return {
              Cbe: { 
                data: {
                  "cbe": {cbeId: '3', name: 'ACCA CBE'},
                  "cbe_sections": [
                    {"id":1,"name":"Section A"},
                    {"id":2,"name":"Section B"},
                    {"id":3,"name":"Section C"}]
                  },
                  "cbe_questions": {
                    [
                      {"id":5,cbe_section_id = "1", "type":"Multiple Choice", 'questions': [
                        {'id': '1', }
                      ]},
                      {"id":6,cbe_section_id = "1", "type":"Multiple Choice"},
                      {"id":7,cbe_section_id = "1", "type":"Multiple Choice"},
                      {"id":8,cbe_section_id = "1", "type":"Multiple Choice"}
                    ]
                }
            }
     }


</script>
