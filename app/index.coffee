require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')

Router = require 'controllers/Router'

realtime      = require 'lib/realtime'
scroller      = require 'lib/scroller'
notifications = require 'lib/notifications'


module.exports = class App extends Stage.Global
	
	
	constructor: (options) ->
		super

		window.android = options.android
	
		Spine.Route.setup()

		Router.active()

		scroller.initialize()
		notifications.initialize()
		realtime.initialize()
		
		

