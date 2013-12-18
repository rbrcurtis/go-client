Model = require './framework/Model'
User = require './User'


module.exports = class Chat extends Model

	constructor: ->
		# debugger
		super

	@attributes:

		id:
			type: String

		user:
			type: User

		text:
			type: String
			
