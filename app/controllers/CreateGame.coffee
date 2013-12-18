{Panel} = require 'spine.mobile'
Spine = require 'spine'
{User,Game} = require 'models'
friends = require 'lib/friends'
pop = require 'lib/pop'
api = require 'lib/api'

module.exports = new class CreateGame extends Panel

	Object.defineProperty @::, 'handicap',
		get: -> if (val = $('.handicap')?.html())? then +val else getCookie('handicapPref') or 4
		set: (val) -> 
			$('.handicap').html(val)
			document.cookie = "handicapPref=#{val}"

	Object.defineProperty @::, 'size',
		get: -> if (val = $('.game-size')?.html())? then +val else getCookie('sizePref') or 9
		set: (val) -> 
			$('.game-size').html(val)
			document.cookie = "sizePref=#{val}"

	Object.defineProperty @::, 'searchBox',
		get: -> return $('#search-box')



	className: 'create-game'

	events:
		'tap div.size-info': 'sizeInfo'
		'tap div.handicap-info': 'handicapInfo'
		'tap div.opponent-info': 'opponentInfo'
		'change #search-box': 'submitSearch'
		'tap .game-size': 'cycleSize'
		'tap .handicap': 'cycleHandicap'
		'tap .random': 'createGame'
		'tap .friend': 'createGame'
		'tap .result': 'createGame'
		'tap .ai': 'createGame'
		'tap .search': 'showSearch'
		'tap .favs': 'showFriends'
		'tap .star': 'star'

	constructor: ->
		super
		
		@friends = []

		User.find ( (user) -> return user.friend ), (err, @friends) =>
			debug 'create', 'friends updated', @friends
			if @current then @render()
		
	active: (@params) ->
		super
		debug 'create', "create screen active", @params
		@current = true
		@render()

	deactivate: ->
		super
		debug 'create', "create screen deactivated"
		@current = false
		
	back: ->
		@navigate '/menu'

	render: ->
		debug 'create', 'render', @handicap, @size
		if @params.showFriends
			debug 'create', 'rendering friends', @friends
			@html require("views/createGame")({@friends, @size, @handicap})
		else if @params.search
			@html require("views/search")({search:true, @searchResults, @query, @size, @handicap})
		else 
			@html require("views/createGame")({@size, @handicap})

		unless @friends.length
			$('.friends').attr 'disabled', 'true'

	opponentInfo: -> pop require('views/opponentInfo')()
	handicapInfo: -> pop require('views/handicapInfo')()
	sizeInfo: -> pop require('views/sizeInfo')()

	cycleSize: ->
		debug 'create', 'size', @size
		@size = switch @size
			when 9 then 13
			when 13 then 19
			when 19 then 9


	cycleHandicap: ->
		@handicap = (@handicap+1)%5

	showFriends: ->
		@navigate '/create/friends'
	
	showSearch: ->
		@navigate "/create", 'handicap', @handicap, 'size', @size, 'search'

	submitSearch: (e) ->
		debug 'search', 'search', e
		if @tid then clearTimeout @tid
		@tid = setTimeout @_submitSearch, 0

	_submitSearch: =>
		@query = @searchBox.val()
		unless @query.length >= 3 then return
		debug 'search', 'submitting', 
		api 'users/search/'+@query,
			'GET'
			null
			(@searchResults) =>
				for u,i in @searchResults
					if u.id in me.friends then u.friend = true
					@searchResults[i] = User.add u
				[start, end] = [@searchBox[0].selectionStart, @searchBox[0].selectionEnd]
				@render()
				@searchBox.focus()
				@searchBox[0].setSelectionRange start, end
			-> console.error 'search error', arguments...
	
	star: (e) ->
		debug 'star', 'target', e.currentTarget, 'id', e.currentTarget.parentNode.id
		friends.toggle e.currentTarget.parentNode.id
		e.stopPropagation()

	createGame: (e) ->
		debug 'create', 'create game', @size, @handicap, e.currentTarget.id

		if e.currentTarget.className in ['friend', 'result']
			opponent = User.get(e.currentTarget.id)
			debug 'create', 'opponent', e.currentTarget.id, opponent
			type = opponent.username
			opponent = opponent.id
		else if e.currentTarget.className is 'ai'
			opponent = 'ai'
			type = 'the AI'
			debug 'create', 'opponent', 'ai'
		else type = 'a random opponent'

		msg = "Challenge #{type} to a size #{@size} game?"
		pop msg, buttons:{Ok:1, Cancel:0}, callback: (e, confirmed) =>
			unless confirmed then return

			api 'challenges', 
				'POST'
				{@size, @handicap, opponent}
				(data) =>
					debug 'create', 'create game api returned', data
					if data.type is 'Challenge'
						if opponent
							msg = "Great! We'll let you know when #{type} responds."
						else msg = "Great! We'll let you know when we've found an opponent for you."
						
						pop msg, buttons: { Ok: true }, callback: => @navigate '/menu'

					else if data.type is 'Game'
						next = =>
							debug 'create', 'create game complete, got a game'
							game = Game.add data
							@navigate '/menu'
							@navigate "/games/#{game.id}"
							if game.isMyTurn() then pop "It's your turn!"
						unless opponent is 'ai'
							pop "We found an opponent for you!", callback: next
						else next()



				(xhr) => alert 'create challenge failed'


				
			






