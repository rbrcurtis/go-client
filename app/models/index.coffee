api = require 'lib/api'

freeze = false

module.exports = 
	Game: require './Game'
	Challenge: require './Challenge'
	User: require './User'
	Me: require './Me'

	loadData: _.debounce(
		->
			if window.location.hash.match /donate.[a-z0-9]{24}.[0-9]+/ then return # OMG A HACK
			freeze = true
			debug 'api', 'loading data'
			success = (data) =>
				@resetData()
				# debug 'router', 'success', arguments
				window.me = @Me.set data
				# users first so setters dont ajax the user
				for user in data.users
					if _.contains data.friends, user.id
						user.friend = true
					@User.add user
				@Game.add game for game in data.games
				@Challenge.add c for c in data.challenges
				freeze = false
				for type, Model of @ then Model._runCallbacks?()

				return

			error = (xhr, textStatus, errorThrown) =>
				freeze = false
				if xhr.status is 401
					console.log 'routing to login'
					window.location.hash = '/welcome'


			api 'me', 'GET', null, success, error
		, CONFIG.debounceWait, true
	)

	resetData: ->
		for name, Model of @
			Model.empty?()
