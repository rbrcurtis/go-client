Model = require './framework/Model'
User = require './User'

module.exports = class Challenge extends Model

	@attributes:
		id:
			type: String
			
		challenger:
			type: User
			
		challenged:
			type: User
		
		size:
			type: Number
		
		handicap:
			type: Number

		created:
			type: Date
