
pendingpops = []
popping = false

module.exports = pop = (text, opts = {}) ->
	debug 'pop', text, pendingpops
	if popping
		debug 'pop', 'queuing pop:', text
		return pendingpops.push arguments
	popping = true
	callback = ->
		opts.callback? arguments...
		popping = false
		if pendingpops.length
			setTimeout (->pop pendingpops.shift()...), 0
	$.prompt(text, _.extend(_.clone(opts), {callback}))



