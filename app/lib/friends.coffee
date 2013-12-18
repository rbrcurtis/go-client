User = require 'models/User'

module.exports = new class Friends

	add: (id) ->
		if id instanceof User
			id = id.id
		if _.contains me.friends, id then return
		me.friends.push id
		User.get(id)?.friend = true
		@_api()

	remove: (id) ->
		if id instanceof User
			id = id.id
		unless _.contains me.friends, id then return
		me.friends = _.without me.friends, id
		User.get(id)?.friend = false
		@_api()

	toggle: (user) ->
		if typeof user is 'string' then user = User.get user
		# unless user? then return
		if user.friend then @remove user.id else @add user.id

	_api: ->
		data = {friends:me.friends}
		debug 'friends', data
		api 'me', 'PUT', data, => 
			debug 'star', 'success, running _runCallbacks'
