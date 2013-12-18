Spine = require 'spine'

api = require 'lib/api'
pop = require 'lib/pop'

module.exports = new class Verify extends Spine.Controller

	className: 'verify'
	
	constructor: ->
		super

	active: (@params) ->
		super
		debug 'verify', 'verify controller active'
		unless @params.code 
			pop 'No verification code specified'
			@navigate '/menu'
			
		api 'verify', 'POST', {code:@params.code},
			=>
				pop 'Thank you for verifying your email.'
				@navigate '/menu'
			=>
				console.error arguments...
				pop 'There was a problem verifying your email address.  if you think you received this message in error, please contact support at support@go-versus.com'
				@navigate '/menu'
