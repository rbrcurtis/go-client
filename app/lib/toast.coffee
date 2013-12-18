


module.exports = (text, callback) ->
	opts = {
		text
		position: 'bottom-center'
		sticky: false
	}
	if callback? then opts.close = callback

	$.toastmessage("showToast", opts)
