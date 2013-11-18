class Snapview
    constructor:(@app, @$view, @$snaps, @direction = 'top', @offsetType = 'offset') ->
        @tipSize = 50
        @setSnaps(@$snaps)
        @snapIdx(0)

    setSnaps: (@$snaps) ->
        @detectSnaps()

    detectSnaps: ->
        @snapTops = []
        @snapBottoms = []
        @snapLefts = []
        @snapRights = []

        @snapLength = 0;
        for snap, idx in @$snaps
            $snap = $(snap)
            @snapLength++;

            if(@offsetType == 'offset')
                offset = $snap.offset()
            else if(@offsetType == 'position')
                offset = $snap.position()
            
            @snapTops.push offset.top
            @snapBottoms.push offset.top + $snap.height()
            @snapLefts.push offset.left
            @snapRights.push offset.left + $snap.width()

        #console.log 'detectSnaps', @snapTops

    scrollTo: (top, left) ->
        left = 0 if @direction == 'top'
        top = 0 if @direction == 'left'
            
        @currentTop = 0-parseInt(top)
        @currentLeft = 0-parseInt(left)

        @$view.css(
            '-webkit-transform', 
            'translate3d(' + @currentLeft + 'px,' + @currentTop + 'px,0)'
        )

    scrollFromActive: (top, left) ->
        left = 0 if @direction == 'top'
        top = 0 if @direction == 'left'

        #console.log 'scrollFromActive', top, left, @direction, @currentTop, @currentLeft, @currentTop-top, @currentLeft-left

        @scrollTo( 
            @snapTops[@activeIdx] - top,
            @snapLefts[@activeIdx] - left
        )

    scrollBy: (top, left) ->
        left = 0 if @direction == 'top'
        top = 0 if @direction == 'left'

        #console.log 'scrollBy', top, left, @direction, @currentTop, @currentLeft, @currentTop-top, @currentLeft-left

        @scrollTo( 
            0-@currentTop+top, 
            0-@currentLeft+left
        )

    snapIdx: (idx) ->
        @activeIdx = idx

        if(@$active)
            @$active.removeClass 'activeSnap'

        @$active = $(@$snaps[idx])
        #console.log 'snap to', idx, @$active.find('h2').text()

        # scroll
        @scrollTo( 
            @snapTops[@activeIdx], 
            @snapLefts[@activeIdx]
        )

        # active class
        @$active.addClass 'activeSnap'

    tipNext: ->
        nextIdx = @activeIdx+1
        console.log 'tipNext', nextIdx, @snapTops, @snapLefts
        if(nextIdx < @snapLength)
            @scrollTo(
                @snapTops[@activeIdx] + @tipSize,
                @snapLefts[@activeIdx]
            )
            if(@tipTimeout)
                clearTimeout @tipTimeout
            # refactor to snapview context
            @tipTimeout = setTimeout(
                (() -> app.main.snapview.unTip())
                , 1000
            )

    tipPrev: ->
        prevIdx = @activeIdx-1
        if(prevIdx >= 0)
            @scrollTo(
                @snapTops[@activeIdx] - @tipSize,
                @snapLefts[@activeIdx]
            )
            if(@tipTimeout)
                clearTimeout @tipTimeout
            # refactor to snapview context
            @tipTimeout = setTimeout(
                (() -> app.main.snapview.unTip())
                , 1000
            )

    unTip: ->
        if(@tipTimeout)
            clearTimeout @tipTimeout

        @scrollTo(
            @snapTops[@activeIdx],
            @snapLefts[@activeIdx]
        )

    snapCurrent: ->
        @snapIdx @activeIdx

    snapNext: ->
        nextIdx = @activeIdx+1
        if(nextIdx < @snapLength)
            @snapIdx nextIdx
            if(@callbackOnNext)
                @callbackOnNext(@activeIdx)

    onNext: (callback) ->
        @callbackOnNext = callback


    snapPrev: ->
        prevIdx = @activeIdx-1
        if(prevIdx >= 0)
            @snapIdx prevIdx
            if(@callbackOnNext)
                @callbackOnNext(@activeIdx)

    onPrev: (callback) ->
        @callbackOnPrev = callback