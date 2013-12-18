device = require 'lib/device'

deviceId = null

device.whenDeviceReady ->
	deviceId = window.device.name+";"+window.device.uuid


module.exports = (url, method, data, onSuccess, onError, onComplete) ->
	debug 'api', 'api call', CONFIG.server, url, method, data, typeof data, onSuccess?

	loc = JSON.stringify google?.loader?.ClientLocation

	adblocker = unless _inmobi? then true else false

	headers = 
		'x-href': window.location.href
		'x-version': CONFIG.version
		'x-adblocker': adblocker
	if loc? then headers['x-location'] = loc
	if deviceId then headers['x-device'] = deviceId

	options = 
		xhrFields:
			withCredentials: true
		url:      CONFIG.server+url
		type:     method
		# dataType: 'json'
		# contentType: 'application/json'
		data:     data
		headers:  headers
		success:  (data) =>
			if typeof data is 'string'
				try
				  data = JSON.parse data
				catch error
			onSuccess? data
				  
		error:    (xhr) =>
			debug 'api', 'error on api call', arguments...
			if xhr.status is 401 then unless url.match /login/ then window.location.hash = '/welcome'
			onError? arguments...
		complete: =>
			debug 'api', 'api call complete', arguments...
			onComplete?()

	$.ajax options
