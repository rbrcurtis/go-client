{Panel} = require 'spine.mobile'
Spine = require 'spine'
{Game,Challenge} = require 'models'

module.exports = new class Menu extends Panel

	className: 'menu'
	events:
		'tap .share': 'share'

	constructor: ->
		super
		Challenge.count (err, @challengeCount) => @render()
		Game.count (err, @gameCount) => @render()

	active: (@params) ->
		super
		@render()
		debug 'menu', "menu active", @params

	render:->
		debug 'menu', @gameCount, @challengeCount
		view = require("views/menu")({@gameCount,@challengeCount})
		@html view
		
	
	share: ->
		debug 'share', 'share button hit', window.plugins?.share?
		if Cordova?.exec?
			window.plugins.share.show
				subject: 'Come play a game of Go with me!'
				text: "Go Versus, online at https://go-versus.com and android https://play.google.com/store/apps/details?id=com.mut8ed.go\n\nMy username is #{me.username}."
				=> debug 'share', 'success', arguments...
				=> console.error 'share', 'fail', arguments...

		else
			@navigate '/share'
