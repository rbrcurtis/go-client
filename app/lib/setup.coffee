window._ = require 'lib/underscore'
window.CONFIG = require 'lib/config'

require('json2ify')
require('es5-shimify')
require('gfx')

require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/manager')
require('spine/lib/route')

require('spine.mobile')

require('./debug')

Spine.Controller.include
	getRoute: ->
		route = window.location.hash
		if route.length>0 and route[0] is '#'
			route = route.substr 1
		if route[route.length-1] is '/'
			route = route.substring(0,route.length-1)
		return route


window.log = (args...) ->
	msg = ""
	# for arg in args
	# 	try
	# 		arg = JSON.stringify(arg)
	# 	catch e
	# 	msg+=" "+arg
	# console.log msg
	console.log args...

window.debug = (type, args...) ->
	if type in window.debugType
		log "#{type}:", args...
	
window.getCookie = (name) ->
	ARRcookies = document.cookie.split(";")
	i = 0
	while i < ARRcookies.length
		x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="))
		y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1)
		x = x.replace(/^\s+|\s+$/g, "")
		return unescape(y)  if x == name
		i++
