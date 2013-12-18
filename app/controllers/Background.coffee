{Panel} = require 'spine.mobile'
Spine = require 'spine'

module.exports = new class Background extends Panel

	className: 'background'
		
	active: (@params) ->
		super

		@render()

	render:->
		@html "<img src = 'https://gravatar.com/avatar/7ca0c9faf9a9c6f9cb3633419f2785ae?s=64&d=identicon' />"
		
		$('#butt').bind 'tap', =>@append '<br/>tap'
