{Panel} = require 'spine.mobile'
{Me} = require 'models'

api = require 'lib/api'
pop = require 'lib/pop'
notifications = require 'lib/notifications'
realtime = require 'lib/realtime'
models = require 'models'

module.exports = new class Settings extends Panel

	className: 'settings'

	events:
		'tap .notif': 'toggleNotif'
		'change .user-setting': 'userSetting'
		'tap .avatar': 'gravatar'
		'tap .realtime': 'reconnect'

	constructor: ->
		super
		Me.get (@me) =>
			if @current
				@render()

		realtime.isConnected (@connected) =>
			if @current
				@render()


	active: (@params) ->
		super
		@current = true
		@render()
		debug 'settings', "settings active", @params

	deactivate: ->
		super
		@current = false

	back: ->
		@navigate '/menu'

	render:->
		debug 'settings', @me?.settings
		@html require("views/settings")()

		if @me?.settings.receiveNotifications in [true, "true"] then $('.notif').addClass('checked')
		else $('#notif').attr('checked', false)

		if @connected
			$('.realtime').removeClass "disconnected"
			$('.realtime').addClass "connected"
		else
			$('.realtime').removeClass "connected"
			$('.realtime').addClass "disconnected"

	gravatar: ->
		pop 'You can change your avatar at <a href="http://gravatar.com">gravatar.com</a> (it\'s free!)'

	reconnect: ->
		realtime.connect()
		models.loadData()

	toggleNotif: ->
		notif = $('.notif')
		checked = notif.hasClass('checked')
		debug 'settings', 'toggleNotif', checked
		@me.settings.receiveNotifications = not checked
		api 'me', 'PUT', settings:@me.settings, null, (->console.error arguments...)
		if checked
			notif.removeClass('checked')
			notifications.deregister()
		else 
			notif.addClass('checked')
			notifications.register()

	userSetting: (e) ->
		el = $(e.currentTarget)
		key = el.attr('id').split('-')[1]
		debug 'settings', key, el.val()
		api 'me', 'PUT', {key:el.val()}, (->debug 'settings', 'success'),
			->
				console.error arguments...
