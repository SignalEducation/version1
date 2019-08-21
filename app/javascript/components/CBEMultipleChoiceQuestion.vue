<template>
	<div>
		<div class="form-group">
			<label for="colFormLabelSm" >Question Name</label>
			<div class="input-group input-group-lg">
					<input v-model="questionName" placeholder="Question Name" class="form-control">
			</div>
		</div>

		<div class="form-group">
			<label for="colFormLabelSm" >Question Description</label>
			<div class="input-group input-group-lg">
			<input v-model="questionDescription" placeholder="Question Description" class="form-control">
		</div>
  </div>

	<div>
		<div class="form-group">
			<div class="input-group input-group-lg">
					<input v-model="question_1" placeholder="Choice 1 Text">
			</div> 
				<input type="radio" id="one" value="1" v-model="correctAnswer">
		</div>

		<div class="form-group">
			<div class="input-group input-group-lg" placeholder="Choice 2">
					<input v-model="question_2" placeholder="Choice 2 Text">
			</div>
			<input type="radio" id="two" value="2" v-model="correctAnswer">
		</div>

		<div class="form-group">
			<div class="input-group input-group-lg">
					<input v-model="question_3" placeholder="Choice 3 Text">
			</div>
			<input type="radio" id="three" value="3" v-model="correctAnswer">
		</div>

		<div class="form-group">
			<div class="input-group input-group-lg">
					<input v-model="question_4" placeholder="Choice 4 Text">
			</div>
			<input type="radio" id="four" value="4" v-model="correctAnswer">
		</div>

		<div class="form-group">
				<button v-on:click="saveNewMultipleChoiceQuestion" class='btn btn-primary'>Save</button>
		</div>   
      
		<div class="form-group">
			<span class="badge badge-pill badge-primary">Selected Section  {{this.$store.state.currentSectionId}}</span>
			<span class="badge badge-pill badge-primary">Current Answer  {{this.correctAnswer}}</span>
		</div>
	</div>
	</div>
</template>

<script>
import axios from 'axios'

export default {
	data: function () {
		return {
			questionDetails: {},
			questionName: null,
			questionDescription: null,
			correctAnswer: null,
			selectedSelectQuestion: null,
			showChoices: false,
			question_1: null,
			question_2: null,
			question_3: null,
			question_4: null,
			multipleChoiceDetails: [],
		}
	},
				
  methods: {
		saveNewMultipleChoiceQuestion: function (page, index) {
			this.multipleChoiceDetails = {}
			this.multipleChoiceDetails['cbe_section_id'] =  this.$store.state.currentSectionId
			this.multipleChoiceDetails['name'] =  this.questionName
			this.multipleChoiceDetails['questionDescription'] =  this.questionDescription
			this.multipleChoiceDetails['question_1'] =  this.question_1
			this.multipleChoiceDetails['question_2'] =  this.question_2
			this.multipleChoiceDetails['question_3'] =  this.question_3
			this.multipleChoiceDetails['question_4'] =  this.question_4
			this.multipleChoiceDetails['correctAnswer'] =  this.correctAnswer
						
			console.log(this.multipleChoiceDetails)
			{cbe_multiple_choice_question: this.cbeDetails}
			axios.post('http://localhost:3000/api/cbe_multiple_choice_questions/', {cbe_multiple_choice_question: this.multipleChoiceDetails} )
				.then(response => {
					console.log(this.multipleChoiceDetails)
					console.log(response.status)
					console.log(response.data)
				})
				.catch(error => {
						console.log(error)
				})
		}
	}
}
</script>

