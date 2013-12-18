{Panel} = require 'spine.mobile'

models = require 'models'

api = require 'lib/api'
pop = require 'lib/pop'

module.exports = new class Donate extends Panel

	className: 'donate'

	events:
		'tap .donate-send': 'submit'

	active: (@params) ->
		super
		debug 'donate', "donate active", @params
		if @params.amount? then @donate()
		else @render()


	render:->
		debug 'donate', @gameCount, @challengeCount
		view = require("views/donate")()
		@html view

	submit: ->

		amount = $('input:radio:checked').val()
		if amount is 'other' then amount = $('#other-input').val()
		donateHash = "#/donate/#{me.id}/#{amount}"
		if navigator?.app?.loadUrl?
			pop "We're taking you to the web browser now to complete your donation. You can return back here afterwards by just hitting the back button.", callback: ->
				navigator.app.loadUrl CONFIG.web+"?mobilereturn=true#{donateHash}",  { openExternal:true }
		else document.location.hash = donateHash


	donate: ->

		debug 'donate', arguments...
		google.load 'payments', '1.0', 
			'packages': [CONFIG.walletPackage],
			callback: =>
				amount = Number @params.amount
				unless amount >= 1 then return

				debug 'donate', 'donating', amount

				api "donation/wallet/#{@params.userId}?amount=#{amount}", 'GET', null, 
					(body) => 
						debug 'donate', 'got jwt', body.jwt
						goog.payments.inapp.buy({
							parameters: {}
							jwt     : body.jwt,
							success : =>
								debug 'donate', 'donation success', arguments...
								models.loadData()
								message = "Thank you SO MUCH.  We truly appreciate your support."
								if window.location.href.match /mobilereturn/ 
									message += "<br/>\nIt looks like you came from the mobile app.  Please hit the back button until you return there now."
									@html "<div style='padding: 30px'>#{message}</div>"

								else
									pop message, callback: => @navigate '/menu'
									
								

							failure : =>
								debug 'donate', 'donation failure', arguments...
						})

					=>
						console.error 'error', arguments...
						pop "Sorry! We can't handle your donation right now! Please try again."

