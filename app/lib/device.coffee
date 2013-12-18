

module.exports = new class DeviceManager

	_readyCallbacks: []
	
	deviceready: false

	constructor: ->
		document.addEventListener 'deviceready', =>
			@deviceready = true
			debug 'device', '****** device ready ******'
			while callback = @_readyCallbacks.pop() then callback()
			
			document.addEventListener 'resume', =>
				models = require 'models'
				models.loadData()
				window.location.hash = '#/menu'

			document.addEventListener 'backbutton', (e) =>
				router = require 'controllers/Router'
				if router.controller.back?
					debug 'device', 'backing out', router.controller.back
					router.controller.back()
				else Cordova.exec(null, null, "App", "backHistory", []);

		# , false
		
		# pause
		# menubutton
		# searchbutton


	whenDeviceReady: (callback) ->
		unless callback then return
		if @deviceready then callback() else @_readyCallbacks.push callback

	isDevice: -> return deviceready


