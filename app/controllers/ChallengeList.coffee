{Panel} = require 'spine.mobile'
Spine = require 'spine'
{Game,Challenge,User} = require 'models'

pop = require 'lib/pop'
api = require 'lib/api'

module.exports = new class ChallengeList extends Panel

	className: 'challenges'
	id: 'challenges'
		
	events:
		'tap .challenge': 'accept'

	challenges: []

	constructor: ->
		super
		debug 'challenge', 'constructor'
		@addButton('Menu', @back)
		Challenge.find ((c)->c.challenged?.id is me?.id), (err, @challenges) =>
			debug 'challenge', 'constructor callback', @challenges
			if @current then @render()
		
	active: (@params) ->
		super
		debug 'challenges', "challenges screen active", @params
		@current = true
		@render()
		
	deactivate: ->
		super
		debug 'challenges', "challenges screen deactivated"
		@current = false
		
	back: ->
		@navigate '/menu'

	render: ->
		debug 'challenges', 'rendering with', @challenges
		@html require("views/challengeList")({@challenges})
	
	accept: (e) =>
		debug 'challenges', 'accept', e
		
		c = _.find @challenges, (c) -> if c.id is e.currentTarget.id then true else false
		username = if c then c.challenger.username else 'unknown'

		cb = (e,v,m,f) =>

			api "challenges/#{c.id}",
				'PUT'
				{challengedAccepts:v}
				success = (data) =>
					debug 'challenges', 'success', data
					c.remove()
					if data?.type is 'Game'
						game = Game.add data
						@navigate '/menu'
						@navigate "/games/#{game.id}"
						if game.isMyTurn()
							pop "It's your turn!", { buttons: { Ok:true }}
				error = ->
					alert 'There was an error making your request; please try again.'



		pop "Accept #{username}'s Challenge?", { buttons: { Yes: true, No: false }, callback:cb }






