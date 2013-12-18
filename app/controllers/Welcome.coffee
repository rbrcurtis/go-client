Spine = require 'spine'
{Panel} = require 'spine.mobile'

Router = require 'controllers/Router'

models = require 'models'

api = require 'lib/api'
pop = require 'lib/pop'
notifications = require 'lib/notifications'
realtime = require 'lib/realtime'

module.exports = new class Welcome extends Panel

	className: 'welcome'
		
	active: (@params) ->
		super
		debug 'welcome', "signin active", params
		@render()
		
		form = $('#welcomeForm')
		form.on 'submit', =>


			pw1 = $('#welcomeForm input[name=password]') 
			pw2 = $('#welcomeForm input[name=password2]')
			terms = $('#terms') 

			debug 'welcome', 'pw2', pw2

			if pw2.length
				if pw1.val() isnt pw2.val()
					pop 'passwords do not match'
					return false
				path = 'register'
			else
				path = 'login'

			# unless terms.attr('checked')?
			# 	pop "You must accept the terms and conditions."
			# 	return false

			debug 'welcome', 'api call to', path
			api(
				path
				'POST'
				form.serialize(), 
				=>
					models.loadData()
					realtime.connect()
					notifications.register()
					@navigate '/menu'
				(xhr) -> 
					console.error arguments...
					if xhr.status in [400, 401] then pop xhr.responseText
				->debug 'welcome', 'complete', arguments
			)

			return false
		
		
	render:->
		@html require("views/#{@params.page}")(invite:@params.invite)
		
