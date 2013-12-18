Model = require './framework/Model'
User = require './User'
Chat = require './Chat'


module.exports = class Game extends Model

	@_url: 'games/{id}'

	@attributes:

		id:
			type: String
			
		white:
			type: User

		black:
			type: User

		turn:
			type: String

		turnCount:
			type: Number
			default: 0

		lastMove:
			type: Object

		size:
			type: Number

		whiteScore:
			type: Number

		blackScore:
			type: Number

		winner:
			type: String
			
		board:
			type: Object

		created:
			type: Date

		updated:
			type: Date

		passes: 
			type: Number

		ended:
			type: Date

		chats:
			type: [Chat]

		color:
			get: ->
				unless @white and @black and me then return ''
				if @white.id is me.id then return 'white'
				else return 'black'
			
		opponent:
			get: ->
				unless @white and @black and me then return {username:'', avatar:'', id:'', rank:''}
				if @white.id is me.id then return @black
				else if @black.id is me.id then return @white

	isMyTurn: ->
		unless @white and @black and me then return false
		return @[@turn].id is me.id
