api = require 'lib/api'
device = require 'lib/device'

module.exports = new class GCM

	initialize: ->
		debug 'gcm', 'GCM init'

		window.receiveNotification = @receiveNotification

		device.whenDeviceReady =>
			debug 'gcm', 'device ready yo'
			window.GCM.init "333428187800",
				"receiveNotification"
				=>
					debug 'gcm', 'init success', arguments...

					Me.get (me) => if me.settings.receiveNotifications in [true, 'true'] then @register()


				->
					debug 'gcm', 'init success', arguments...


	register: ->
		debug 'gcm', 'register called'
		unless window.GCM?.register? then return console.log "no GCM on the window"
		window.GCM.register(
			->
				debug 'gcm', 'register success', arguments...
			->
				debug 'gcm', 'register success', arguments...
		)
	deregister: ->
		debug 'gcm', 'deregister called'
		unless window.GCM?.unregister? then return console.log "no GCM on the window"
		window.GCM.unregister(
			->
				debug 'gcm', 'unregister success', arguments...
			->
				debug 'gcm', 'unregister success', arguments...
		)

	receiveNotification: (e) =>
		debug 'gcm', 'received notification', e
		if e.event is 'registered'
			api 'notifications/register', 'POST', {type:'android', token:e.regid},
				-> debug 'gcm', "register success"
				-> debug 'gcm', "register failed", arguments...
