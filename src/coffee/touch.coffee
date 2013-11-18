class Touch
    constructor: (@app) ->
        @dom()
        @events()
        @lock = false
        @dragLimitX = 50
        @dragLimitY = 100

    dom: ->

    subs: ->

    events: ->
        console.log 'touch events'
        hammertime = $("body").hammer { drag_lock_to_axis: true }
        
        hammertime.on "drag", (e)-> e.gesture.preventDefault()

        hammertime.on "dragup dragdown", (e)-> app.touch.dragY(e)
        hammertime.on "dragleft dragright", (e)-> app.touch.dragX(e)
        hammertime.on "dragend", (e)-> app.touch.dragEnd(e)

        hammertime.on "swipeup", (e)-> app.touch.swipeUp(e)
        hammertime.on "swipedown", (e)-> app.touch.swipeDown(e)
        hammertime.on "swipeleft", (e)-> app.touch.swipeLeft(e)
        hammertime.on "swiperight", (e)-> app.touch.swipeRight(e)                

    dragY: (e) ->
        e.gesture.preventDefault()

        console.log 'dragY', @lock, e.gesture.direction, e.gesture.deltaY

        if(!@lock)
            delta = e.gesture.deltaY
            direction = e.gesture.direction

            if(delta > @dragLimitY || delta < 0-@dragLimitY)
                @lock = true
                @app.$body.removeClass('drag')

                if (@app.mode == @app.modeMain)
                    if direction == 'up'
                        @app.main.snapview.snapNext()
                    else if direction == 'down'
                        @app.main.snapview.snapPrev()
                else if(@app.mode == @app.modeRead)
                    @app.main.currentArticle.unRead()
                    @app.main.snapview.snapCurrent()

            else # drag
                console.log 'draaaag'
                @app.$body.addClass('drag')
                @app.main.snapview.scrollFromActive(e.gesture.deltaY,0)

    dragX: (e) ->
        e.gesture.preventDefault()

        console.log 'dragX',@lock, e.gesture.direction, e.gesture.deltaX, 0-@dragLimitX

        if(!@lock)
            delta = e.gesture.deltaX
            direction = e.gesture.direction

            #@app.main.currentArticle.read()
            if(delta > @dragLimitX || delta < 0-@dragLimitX)
                @lock = true
                @app.$body.removeClass('drag')

                if(@app.mode == @app.modeMain)
                    if direction == 'left'
                        @app.main.currentArticle.read()
                else if(@app.mode == @app.modeRead)
                    if direction == 'left'
                        console.log 'dragX next'
                        @app.main.currentArticle.snapview.snapNext()
                    else if direction == 'right'
                        console.log 'dragX prev'
                        @app.main.currentArticle.snapview.snapPrev()

            else # drag
                console.log 'draaaag'
                @app.$body.addClass('drag')

                if(@app.main.currentArticle)
                    @app.main.currentArticle.snapview.scrollFromActive(0,delta)

    dragEnd: (e) ->
        e.gesture.preventDefault()
        @app.$body.removeClass('drag')

        console.log 'dragEnd', e.gesture.deltaY

        if(@app.mode == @app.modeMain && !@lock)
            @app.main.snapview.snapCurrent()
        else if(@app.mode == @app.modeRead && !@lock)
            @app.main.snapview.snapCurrent()
            @app.main.currentArticle.snapview.snapCurrent()

        @lock = false

    swipeUp:(e) ->
        e.gesture.preventDefault()
        console.log 'swipeUp', @lock

        if(!@lock)
            @lock = true
            if(@app.mode == @app.modeRead)    
                @app.main.currentArticle.unRead()
            else if(@app.mode == @app.modeMain)
                @app.main.snapview.snapNext()

    swipeDown:(e) ->
        e.gesture.preventDefault()
        console.log 'swipeDown', @lock

        if(!@lock)
            @lock = true
            if(@app.mode == @app.modeRead)
                @app.main.currentArticle.unRead()
            else if(@app.mode == @app.modeMain)
                @app.main.snapview.snapPrev()

    swipeLeft:(e) ->
        e.gesture.preventDefault()
        console.log 'swipeLeft', @lock

        @app.main.snapview.unTip()
        if(!@lock)
            @lock = true
            if(@app.mode == @app.modeMain)
                @app.main.currentArticle.read()
            else if(@app.mode == @app.modeRead)
                console.log 'swipeLeft next'
                @app.main.currentArticle.snapview.snapNext()

    swipeRight:(e) ->
        e.gesture.preventDefault()
        console.log 'swipeRight', @lock

        @app.main.snapview.unTip()
        if(!@lock)
            @lock = true
            if(@app.mode == @app.modeRead)
                console.log 'swipeRight prev'
                @app.main.currentArticle.snapview.snapPrev()
