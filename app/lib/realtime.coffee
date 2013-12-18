models = require 'models'
toast = require 'lib/toast'

module.exports = new class Realtime

	_connectedCallbacks: []

	initialize: ->
		debug 'realtime', 'init'

		@conencted = false
		@disconnected = Date.now()

		@connect()

	isConnected: (callback) ->
		unless callback?
			return @connected

		@_connectedCallbacks.push callback
		callback @connected

	connect: ->
		if @socket?.socket?.connected then return
		try
			@socket?.socket?.disconnect()
		catch e
		debug 'realtime', 'connect called'
		if @socket?
			@socket.socket.connect()
		else
			@socket = window.io.connect CONFIG.server
			@socket.on 'connect', @onConnect
			@socket.on 'disconnect', @onDisconnect
			@socket.on 'error', @onError

	onConnect: =>
		debug 'realtime', 'connected'
		@connected = true
		@_runCallbacks()
		@socket.on 'event', => @onEvent arguments...

		if @disconnected
			models.loadData()
			@disconnected = null

	_runCallbacks: ->
		callback @connected for callback in @_connectedCallbacks

	onDisconnect: =>
		debug 'realtime', 'disconnected'
		@connected = false
		@disconnected = Date.now()
		@_runCallbacks()

	onError: =>	
		debug 'realtime', 'error', arguments...
		setTimeout (=>@connect()), 10000

	onEvent: (event) ->
		debug 'events', 'event received', event.documentType, event.documentId

		if event.summary
			if event.documentType is 'Game'
				game = event.document
				debug 'events', 'game event, currently at hash', window.location.hash, window.location.hash is '#/games/'+game.id
				if event.document.ended or window.location.hash isnt '#/games/'+game.id
					toast event.summary, ->
						window.location.hash = '#/games'
						window.location.hash = '#/games/'+game.id
			else toast event.summary

		try
			Model = require "models/#{event.documentType}"

			if event.action in ['create', 'update']
				Model.update event.document
			else
				Model.remove event.documentId
				
		catch e
			debug 'events', 'model update', event.documentType, event.document, e

		for Type, dict of event.meta
			try
				Model = require "models/#{Type}"
				for id, model of dict
					debug 'events', 'update', Type, model
					Model.update model
			catch e
				debug 'events', 'meta update', Type, dict, id, model, e

