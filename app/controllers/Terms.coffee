{Panel} = require 'spine.mobile'

module.exports = new class Terms extends Panel

	className: 'terms'


	active: (@params) ->
		super
		@render()

	render:->
		@html require('views/terms')
		
	
