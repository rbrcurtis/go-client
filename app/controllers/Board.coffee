{Panel} = require 'spine.mobile'
Spine = require 'spine'
{Game} = require 'models'
friends = require 'lib/friends'
toast = require 'lib/toast'
pop = require 'lib/pop'
api = require 'lib/api'
device = require 'lib/device'

module.exports = new class Board extends Panel

	className: 'board'
		
	events:
		'tap .cell': 'select'
		'tap .star': 'star'
		'tap .zoom-in': 'zoomIn'
		'tap .zoom-out': 'zoomOut'
		'touchstart #zoom-wrapper': 'scroll'
		'touchmove  #zoom-wrapper': 'scroll'
		'touchend   #zoom-wrapper': 'scroll'
		'tap .confirm': 'confirm'
		'keyup .chat-input': 'chat'

	size: 1
		
	constructor: ->
		super
		log 'board', 'board created'
		
		$(window).on 'resize', =>
			if @current then @setSize @size

		@isDevice = false
		device.whenDeviceReady =>
			@isDevice = true
			@render()
			@setSize @size

	active: ({@gameId, @page}) ->
		super
		@current = true
		log 'board active', @gameId

		@watchGame @gameId

		if @page is 'board'
			debug 'board', 'toast check', @game?.id, @gameId, @game?.turnCount
			if @game?.turnCount <= 2 
				if @isDevice
					toast 'Tap the checkmark to confirm a move or pass'
				else
					toast 'Click the checkmark to pass'

	deactivate: ->
		super
		debug 'board', "games screen deactivated", @gameId
		@current = false

	back: ->
		@navigate '/games'

	render: ->
		unless @game then return
		@html require('views/board')({@game, @isDevice, @page})
		if @page is 'chat'
			chats = $('div.chats')
			chats.scrollTop chats[0].scrollHeight
			$('.chat-input').focus()

	watchGame: (gameId) ->
		@games ?= {}
		callback = if @games[gameId] then null else (err, game) =>
			debug 'board', 'game update', @gameId, game?.id, @current
			unless game?.id is @gameId and @current then return
			debug 'board', 'game updating', @gameId
			@game = game
			@render()
			@setSize(1)
		@games[gameId] = true
		debug 'board', 'watching game', gameId
		@game = Game.get gameId, callback
		if @game?
			@render()
			@setSize(1)


	select: (e) ->
		unless @game.isMyTurn() then return
		if @game.ended? then return

		(selected = $('.cell.selected')).removeClass('selected').removeClass('selected-highlight')
		target = $(e.target)
		
		if selected.attr('id') is target.attr('id')
			$('.confirm').removeClass('highlight')
			return

		target.addClass 'selected'

		unless @isDevice then return @confirm()

		target.addClass 'selected-highlight'
		

		$('.confirm').addClass('highlight')

	confirm: ->
		unless @game.isMyTurn() then return
		if @game.ended? then return
		
		[x,y] = $('.cell.selected').attr('id')?.split('|') or [null,null]
		debug 'board', 'select', {x,y}

		call = (url) ->
			api url, 'POST', null, (result) =>
				debug 'board', 'result', result
				Game.update result

		if x? and y?
			@game.board[x][y] = @game.color
			@game.turn = if @game.turn is 'black' then 'white' else 'black'
			call "games/#{@game.id}/board/#{x}/#{y}" 

		else 
			pop "Would you like to pass?", buttons:{Ok:true, Cancel:false}, callback: (e, confirmed) =>
				if confirmed then call "games/#{@game.id}/pass"
				else return
		

	star: (e) ->
		friends.toggle @game.opponent

	scroll: (e) ->
		switch e.type 
			when 'touchstart'
				@_scrollStartY = e.currentTarget.scrollTop
				@_touchStartY = e.originalEvent.touches[0].pageY
				@_scrollStartX = e.currentTarget.scrollLeft
				@_touchStartX = e.originalEvent.touches[0].pageX
			when 'touchend'
				@_scrollStartY = null
				@_touchStartY = null
				@_scrollStartX = null
				@_touchStartX = null
			else
				unless @_touchStartY? and @_touchStartX then return
				moveToY = @_touchStartY - e.originalEvent.touches[0].pageY + @_scrollStartY
				e.currentTarget.scrollTop = moveToY
				moveToX = @_touchStartX - e.originalEvent.touches[0].pageX + @_scrollStartX
				e.currentTarget.scrollLeft = moveToX
				e.preventDefault()


	setSize: (@size) ->
		unless @game then return
		if @size<1 then @size = 1
		debug 'zoom', 'zoom in'
		body = $('article.viewport')
		board = $("#game-board")
		zoom = $('#zoom-wrapper')
		px = body.width()
		debug 'zoom', 'body width', px
		zoom.width px
		zoom.height px+15
		mult = Math.floor px*@size
		board.width mult
		board.height mult
		$('#game-board td').height(Math.floor(mult/(@game.size+2)))
		$('#game-board td').width(Math.floor(mult/(@game.size+2)))

	zoomIn: ->
		debug 'zoom', 'zoom in'
		@setSize(@size*1.3)

	zoomOut: ->
		debug 'zoom', 'zoom out'
		@setSize(@size*.8)


	chat: (e) ->
		debug 'chat', 'chat input', e
		if e.keyCode is 13 and not e.shiftKey
			api "games/#{@gameId}/chats", 'POST', {text:$('.chat-input').val()},
				(data) => Game.add data





