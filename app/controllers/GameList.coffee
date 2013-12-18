{Panel} = require 'spine.mobile'
Spine = require 'spine'
{Game} = require 'models'
friends = require 'lib/friends'

module.exports = new class GameList extends Panel

	className: 'game-list'

	events:
		'tap .game': 'view'
		'tap .star': 'star'

	games: []

	constructor: ->
		super
		Game.find (->return true), (err, games) => 

			games = _.sortBy games, (g) =>
				if g.isMyTurn() then "0#{g.opponent.username}"
				else "1#{g.opponent.username}"

			@games = games
			if @current then @render()

	active: (@params) ->
		super
		debug 'games', "games screen active", @params
		@current = true
		@render()
		
	deactivate: ->
		super
		debug 'games', "games screen deactivated"
		@current = false

	back: ->
		@navigate '/menu'

	render:->
		debug 'games', @games
		view = require("views/gameList")({@games})
		@html view

	view: (e) ->
		game = _.find @games, (game) -> if game.id is e.currentTarget.id then true else false
		if game then @navigate "/games/#{game.id}"

	star: (e) ->
		game = _.find @games, (game) -> if game.id is e.currentTarget.parentNode.id then true else false
		friends.toggle game.opponent
		e.stopPropagation()

