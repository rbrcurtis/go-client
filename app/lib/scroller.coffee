

module.exports =
	initialize: ->
		$('.viewport').on 'touchstart touchmove touchend', '.panel.active article', (e) =>
			switch e.type 
				when 'touchstart'
					@_scrollStartY = e.currentTarget.scrollTop
					@_touchStartY = e.originalEvent.touches[0].pageY
					@_scrollStartX = e.currentTarget.scrollLeft
					@_touchStartX = e.originalEvent.touches[0].pageX
				when 'touchend'
					@_scrollStartY = null
					@_touchStartY = null
					@_scrollStartX = null
					@_touchStartX = null
				else
					unless @_touchStartY? and @_touchStartX then return
					moveToY = @_touchStartY - e.originalEvent.touches[0].pageY + @_scrollStartY
					e.currentTarget.scrollTop = moveToY
					moveToX = @_touchStartX - e.originalEvent.touches[0].pageX + @_scrollStartX
					e.currentTarget.scrollLeft = moveToX
					e.preventDefault()
