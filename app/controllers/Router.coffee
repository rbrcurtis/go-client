Spine = require 'spine'

models = require 'models'

module.exports = new class Router extends Spine.Controller
	
	constructor: ->
		super
	
		debug 'router', "router created"
		
		models.loadData()
		@setupRoutes()

	active: ->
		log 'router active'
		debug 'router', "route is '#{@getRoute()}'"
		if @getRoute() is '' or @getRoute() is '/' then @navigate '/menu'

	changePage: (@controller, params) ->
		debug 'router', "navigating to #{@controller['className']}", params
		@controller.active(params)

	setupRoutes: ->
		@routes
			'/background':			  (params) -> @changePage (require 'controllers/Background'), params
			'/games':				  (params) -> @changePage (require 'controllers/GameList'), params
			'/games/:gameId':		  (params) -> @changePage (require 'controllers/Board'), _.extend(params, {page:'board'})
			'/games/:gameId/chat':    (params) -> @changePage (require 'controllers/Board'), _.extend(params, {page:'chat'})
			'/create':				  (params) -> @changePage (require 'controllers/CreateGame'), params
			'/create/friends':		  (params) -> @changePage (require 'controllers/CreateGame'), _.extend(params, {showFriends:true})
			'/create/handicap/:handicap/size/:size/search':	(params) -> @changePage (require 'controllers/CreateGame'), _.extend(params, {search:true})
			'/challenges':			  (params) -> @changePage (require 'controllers/ChallengeList'), params
			'/menu':				  (params) -> @changePage (require 'controllers/Menu'), params
			'/welcome':				  (params) -> @changePage (require 'controllers/Welcome'), _.extend(params, {page:'welcome'})
			'/welcome/signin':		  (params) -> @changePage (require 'controllers/Welcome'), _.extend(params, {page:'signin'})
			'/welcome/signin/:invite':(params) -> @changePage (require 'controllers/Welcome'), _.extend(params, {page:'signin'})
			'/welcome/register':	  (params) -> @changePage (require 'controllers/Welcome'), _.extend(params, {page:'register'})
			'/welcome/register/:invite':(params) -> @changePage (require 'controllers/Welcome'), _.extend(params, {page:'register'})
			'/welcome/:invite':       (params) -> @changePage (require 'controllers/Welcome'), _.extend(params, {page:'welcome'})
			'/settings':              (params) -> @changePage (require 'controllers/Settings'), params
			'/donate':                (params) -> @changePage (require 'controllers/Donate'), params
			'/donate/:userId/:amount':(params) -> @changePage (require 'controllers/Donate'), params
			'/share':                 (params) -> @changePage (require 'controllers/Share'), params
			'/terms':                 (params) -> @changePage (require 'controllers/Terms'), params
			'/verify/:code':          (params) -> @changePage (require 'controllers/Verify'), params
		
