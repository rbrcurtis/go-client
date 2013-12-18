api = require 'lib/api'

module.exports = class Model

	### private static ###

	@_url: ''

	@_configure: ->
		if @_configured then return
		@_configured = true
		@_records = []
		@_filters = [] # [filter, callback]
		@_pending = [] # list of ids pending GET
		@_countCallbacks = []
		@_getCallbacks = []

	### public static ###

	@attributes: {}

	@empty: ->
		@_configure()
		@_records = []
		@_runCallbacks()

	# get a record by id
	# @param callback to call with the given record, 
	# 	will be saved and called whenever callbacks fired
	@get: (id, callback) ->
		@_configure()
		debug 'model', 'get', @constructor.name, id
		
		unless id and typeof id is 'string' then return callback? "invalid id specified"

		if callback?
			@_getCallbacks.push {id, callback}

		model = _.find @_records, (r) -> r.id is id

		if model?
			callback? null, model
			return model

		# else load it from the server
		if _.contains @_pending, id then return
		@_pending.push id

		api @_url.replace(/{id}/g, id), 
			'GET'
			null
			(data, textStatus, xhr) =>
				model = new @ data
				@add(model)
				callback? null, model
				@_pending = _.without @_pending, id
				@_runCallbacks()
			(xhr, textStatus, errorThrown) =>
				@_pending = _.without @_pending, id
				callback? textStatus

		return null


	# update a record
	@update: (obj) -> @add arguments...

	# get models that match criteria
	# @param filter truth test function
	# @param callback called with matching models now and when new ones added in future
	@find: (filter, callback) ->
		@_configure()
		unless filter then return @_records
		if callback 
			@_filters.push [filter, callback]
		ret = _.filter(@_records, filter)
		callback?(null, ret)
		return ret


	# add a model to the store
	# @param a model
	# @return the model
	@add: (model, callback) ->
		@_configure()
		debug 'model', 'add', @name
		unless model instanceof @
			model = new @(model)

		for m, pos in @_records
			if m.id is model.id
				@_records[pos] = model
				dup = true
				break

		unless dup then @_records.push model
		debug 'model', 'count', @name, @_records.length

		if callback?
			@_getCallbacks.push {id:model.id, callback}
		
		# note that this will run the just added callback
		@_runCallbacks(model)

		return model

	@remove: (id) ->
		@_configure()
		@_records = _.reject @_records, (r) -> r.id is id
		@_runCallbacks()

	@_runCallbacks: _.debounce (->
		for [filter, callback] in @_filters
			callback(null, _.filter(@_records, filter))
		
		for callback in @_countCallbacks then callback null, @_records.length
		for {id,callback} in @_getCallbacks then callback null, @get id

		return
		), CONFIG.debounceWait


	# get a count of records
	# @param callback called with count immediately and whenever count changes
	@count: (callback) ->
		@_configure()
		if callback
			@_countCallbacks.push callback
			callback null, @_records.length
		return @_records.length



	### public ###

	constructor: (data) ->
		@constructor._configure()
		debug 'model', 'constructor for', @constructor.name, {data}

		Object.defineProperty @, '_values', {value: [], enumerable: false}
		Object.defineProperty @, 'changes', {writable: true, enumerable: false}

		for key, obj of @constructor.attributes
			@_defineAttribute key, obj
			
			
		
		unless data then return
		for key, obj of @constructor.attributes
			if data[key] then @[key] = data[key]
		
		delete @changes

	remove: ->
		debug 'model', 'remove', @constructor._records
		@constructor._records = _.reject @constructor._records, (r) => r.id is @id
		@constructor._runCallbacks()
		return

	toString: ->
		return JSON.stringify @valueOf()
		
	toJSON: ->
		return @valueOf()

	valueOf: ->
		ret = {}
		for key of @constructor.attributes
			if @[key] isnt undefined then ret[key] = @[key].valueOf?() or @[key]
		return ret


	### private ###
		
	_setter: (key, obj) ->
		return (val) ->
			debug 'model', 'set', key, val, obj
			if obj.set? and typeof obj.set is 'function' then val = obj.set(val)
			
			invalidMsg = "invalid value #{val} for type #{obj.type}"
			unless val? then throw Error invalidMsg
			
			validate = (Type, val, obj) =>
				debug 'model', 'validate', typeof Type, val, {model:Type.__super__?.constructor is Model}
				valid = null
				
				if Type is Number
					if isNaN val then valid = false
					else
						val = Number val
						valid = true
					
				else if Type is String
					val = String val
					valid = true
					
				else if Type is Object
					valid = true
					
				else if Type is Date
					if val instanceof Date
						valid = true
					else if typeof val is 'string'
						val = new Date val
						if isNaN(val.getTime()) then valid = false
						else valid = true
					else valid = false

				else if Type is Boolean
					switch typeof val
						when 'boolean'
							valid = true
						when 'string'
							if val in ['true', 'false']
								val = Boolean val
								valid = true
						else
							valid = false

				else if @_isModel Type
					debug 'model', Type, 'instanceof Model'
					unless val instanceof Type
						debug 'model', 'coercing', val, 'into a', Type.name
						
						callback = (err, model) =>
							if model?
								unless obj.type instanceof Array
									@[key] = model
								@constructor._runCallbacks()

						if typeof val is 'string'
							val = Type.get val, callback
						else 
							val = Type.add val, callback
							
					valid = true

				else throw Error "not sure how to deal with Type #{obj.Type}" 
						
				unless valid then throw Error invalidMsg

				return val
				
			if obj.type?
				if obj.type instanceof Array
					unless val instanceof Array then throw Error invalidMsg
					for o, pos in val
						val[pos] = validate obj.type[0], o, obj
				
				else val = validate obj.type, val, obj
				
			if obj.validate? and typeof obj.validate is 'function'
				if (res = obj.validate val) isnt true then throw Error res
			
			@changes ?= {}
			@changes[key] = @_values[key]
			@_values[key] = val
			@constructor._runCallbacks()


	_getter: (key, obj) ->
		return ->
			val = @_values[key]
			if obj.get? and typeof obj.get is 'function' then val = obj.get.apply( @, [val])
			return val

	_isModel: (Type) ->
		try
			return Type.__super__.constructor is Model
		catch e
			return false
		
	_defineAttribute: (key, obj) ->
		debug 'model', @constructor.name, 'key', key, obj
			
		Object.defineProperty @, key, {
			set: @_setter(key, obj)
			get: @_getter(key, obj)
			enumerable: false
		}

		if obj.default? 
			if typeof obj.default is 'function' then @[key] = obj.default()
			else @_values[key] = obj.default
			
			
	
