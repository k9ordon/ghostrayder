class Mousewheel
    constructor: (@app) ->
        #console.log 'constructor', @, @app

        @lock = false
        setTimeout(
            () -> app.mousewheel.events()
            1000
        )
        #@events()

    events: ->
        #console.log 'events', @, @app
        $(window).bind 'mousewheel', (e, delta, deltaX, deltaY) -> app.mousewheel.mousewheelHandler(e, delta, deltaX, deltaY)

    mousewheelHandler: (e, delta, deltaX, deltaY) ->
        #console.log 'mousewheelHandler', delta, @lock
        
        if delta == 1 || delta == -1 || delta == 0 
            @idle()
        else if @lock == true 
            @locked()
        else if deltaY < -15
            @downFast()
        else if deltaY < -1
            @down()
        else if deltaY > 15
            @upFast()
        else if deltaY > 1
            @up()
        else if deltaX < -1
            @rightFast()
        else if deltaX < -1
            @right()
        else if deltaX > 1
            @leftFast()
        else if deltaX > 1
            @left()
        else console.log 'whuuut?'

        return false

    idle: ->
        #console.log 'idle'

    locked: ->
        #console.log 'locked'

    down: ->
        #console.log 'down'
        if(@app.mode == @app.modeMain)
            app.main.snapview.tipNext()

    downFast: ->
        console.log 'downFast'
        @lock = true

        setTimeout (() -> app.mousewheel.lock = false), 700
        
        if(@app.mode == @app.modeRead)
            @app.main.currentArticle.unRead()
        else if(@app.mode == @app.modeMain)
            @app.main.snapview.snapNext()

    up: ->
        #console.log 'up' 
        if(@app.mode == @app.modeMain)
            @app.main.snapview.tipPrev()

    upFast: ->
        console.log 'upFast'
        @lock = true

        setTimeout (() -> app.mousewheel.lock = false), 700

        if(@app.mode == @app.modeRead)
            @app.main.currentArticle.unRead()
        else if(@app.mode == @app.modeMain)
            @app.main.snapview.snapPrev()
        

    right: ->
        #console.log 'right'

    rightFast: ->
        console.log 'rightFast' 
        @lock = true
        setTimeout (() -> app.mousewheel.lock = false), 700
        
        @app.main.snapview.unTip()
        
        if(@app.mode == @app.modeRead)
            @app.main.currentArticle.snapview.snapPrev()
        

    left: ->
        #console.log 'left'

    leftFast: ->
        console.log 'leftFast' 
        @lock = true
        setTimeout (() -> app.mousewheel.lock = false), 700
        
        @app.main.snapview.unTip()
        
        if(@app.mode == @app.modeMain)
            @app.main.currentArticle.read()
        else if(@app.mode == @app.modeRead)
            @app.main.currentArticle.snapview.snapNext()
        
