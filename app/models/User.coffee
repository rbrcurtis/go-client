Model = require './framework/Model'

module.exports = class User extends Model

	@_url: 'users/{id}'

	@attributes:
		id:
			type: String

		username:
			type: String

		avatar:
			type: String
			set: (val) -> 
				(new Image()).src = val #preload avatars
				return val

		rank:
			type: String
			
		friend:
			type: Boolean
			default: false


	constructor: (data) ->
		data.friend ?= data.id in me.friends
		super

