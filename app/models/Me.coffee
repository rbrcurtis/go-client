Model  = require './framework/Model'
User = require './User'

module.exports = class Me extends Model

	@attributes:
		id:
			type: String

		created:
			type: Date

		username:
			type: String

		email:
			type: String

		avatar:
			type: String

		rank:
			type: String

		friends:
			type: [String]
			default: []

		settings:
			type: Object

		subscribed:
			type: Boolean

	@get: (callback) ->
		@_configure()
		if callback?
			@_getCallbacks.push callback
			callback? @_records[0]
		return @_records[0]

	@set: (data) ->
		@_configure()
		@_records = []
		ret = @add data
		@_runCallbacks()
		return ret
			
	@_runCallbacks: _.debounce (->
		for callback in @_getCallbacks
			callback @_records[0]
		), @debounceWait
