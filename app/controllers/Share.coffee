{Panel} = require 'spine.mobile'

api = require 'lib/api'
pop = require 'lib/pop'

module.exports = new class Share extends Panel

	className: 'share'

	events:
		'tap .send': 'send'


	controller: ->
		super

	active: ->
		super
		@render()

	render: ->
		debug 'share', 'rendering'
		@html require('views/share')()


	send: ->
		debug 'share', 'send tapped'
		if (recipients = $('.share-to').val()?.trim())
			api 'share', 'POST', {recipients}
			pop "Thank you, we'll send your invite out right away."

			@navigate '/menu'
