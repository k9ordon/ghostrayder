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
        

class Keys
    constructor:(@app) ->
        @events()

    events: ->        
        $(document).bind 'keydown', 'down', (e) ->
            if(app.mode == app.modeRead)
                app.main.currentArticle.unRead()
            else if(app.mode == app.modeMain)
                app.main.snapview.snapNext()
            #e.preventDefault()

        $(document).bind 'keydown', 'up', () ->                
            if(app.mode == app.modeRead)
                app.main.currentArticle.unRead()
            else if(app.mode == app.modeMain)
                app.main.snapview.snapPrev()

        $(document).bind 'keydown', 'right', (e) ->
            if(app.mode == app.modeMain)
                app.main.currentArticle.read()
            else if(app.mode == app.modeRead)
                app.main.currentArticle.snapview.snapNext()

        $(document).bind 'keydown', 'left', () ->
            if(app.mode == app.modeMain)
                #app.main.currentArticle.read()
            else if(app.mode == app.modeRead)
                app.main.currentArticle.snapview.snapPrev()


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
class Header
    constructor: (@app) ->
        @dom()
        @events()

        if(@$headerImg.length > 0)
            if (@$headerImg.get(0).complete)
                @headerDesign()
            else
                @$headerImg.load () ->
                    app.header.headerDesign()
        else
            @app.$body.addClass 'ready'


    dom: ->
        @$header = $('body > header')
        @$h1 = $('body > header h1')

        @$headerCover = @$header.find('#header-cover')
        @$headerImg = @$header.find('#header-cover img')

    events: ->
        @$h1.bind 'click', (e)-> 
            e.preventDefault()
            app.main.snapview.snapIdx 0

    headerDesign: ->
        console.log 'header design', @$headerCover, @app.wHeight

        @app.$body.removeClass 'ready'
        @$headerCover.height @app.wHeight

        window.BackgroundCheck.init { 
            targets: '.bc', 
            #images: 'body', 
            #changeParent: true, 
            threshold: 70
        }
        $nextAs = $('.next-article a')
        $firstNextA = $nextAs.eq(0)
        $nextAs.addClass 'background--light' if $firstNextA.is '.background--light'
        $nextAs.addClass 'background--dark' if $firstNextA.is '.background--dark'

        colorThief = new window.ColorThief()

        headerColors = colorThief.getPalette(@$headerImg.get(0), 2)
        headerColor = colorThief.getColor @$headerImg.get(0)

        #console.log('articleCheaderarticleColors, ("color:rgb(" + (headerColors[0].join(',')) + ")"))
        
        $("<style type='text/css'>"+
            "body > main > article > header .meta section.tags, "+
            "body > main > article > header .meta section span, "+
            "body > main .next-article a,"+
            "body > main > article > .column-content a, "+
            "body > main > article > .column-content b "+
            "{ color:rgb(" + (headerColors[2].join(',')) + "); }"+

            "body > main > article > .more > .more-button, "+
            "body > main > article.column-ready > .column-content > .column:after, "+
            "body > main > article > header h2 a, "+
            "body > main > article > .column-content h2, "+
            "body > main > article > .column-content h3 "+
            "{ color:rgb(" + (headerColors[0].join(',')) + "); }"+

            #"body > main > article > .more, "+
            "body > main > article > .column-content > .column, "+
            "body > main > article > .more > .more-button, "+
            "body > main > article > header "+
            "{ border-color:rgb(" + (headerColors[0].join(',')) + "); }"+

            #"body > main > article > header .meta section span "+
            #"{ border-color:rgb(" + (headerColors[2].join(',')) + "); }"+

            "body "+
            "{ background-color:rgb(" + (headerColor.join(',')) + "); }"+

            "#titlebar "+
            "{ background-color:rgba(" + (headerColor.join(',')) + ",0.6); }"+
            
            #"{ border-color:rgb(" + (headerColors[1].join(',')) + "); }"+
            " </style>"
        ).appendTo("head");
    
        ###
        @$headerCover.blurjs({
            source: 'body',
            radius: 10,
            overlay: 'rgba('+(headerColor.join(','))+',0.3)'
        });
        ###

        @app.$body.addClass 'ready'
class Article
    constructor: (@app, @$article)->
        @dom()
        @createLayout()
        @events()
        @subs()

    subs: ->
        @$snaps = $('header, .column-content > .column', @$article)
        @snapview = new Snapview @app, @$target, @$snaps, 'left', 'position'

    dom: ->
        @$header = $('header', @$article)
        @$coverImg = $('.content img:not([src=""])', @$article).eq(0)
        
        @$content = $('.content', @$article)
        @$target = $('.column-content', @$article)

        @$more = $('.more', @$article)
        @$moreButton = $('.more-button', @$article)

    createLayout: ->

        # color post title background
        if(@$coverImg.length && @$coverImg.length > 0 && @$coverImg.get(0).src.indexOf(window.location.host) == 7)
            @$coverImg.load ()-> 
                colorThief = new ColorThief
                articleColor = colorThief.getColor(this)
                $(this.parentNode).parents('article').find('header .header-cover').css 'backgroundColor', 'rgba(' + articleColor.join(',') + ',0.1)'

        # create column layout
        ## #
        
        @$content.find('p:empty').remove()
        @$content.find('table, thead, tbody, tfoot, colgroup, caption, label, legend, script, style, textarea, button, object, embed, tr, th, td, li, h1, h2, h3, h4, h5, h6, form').addClass('dontsplit');
        @$content.find('h1, h2, h3, h4, h5, h6').addClass('dontend');
        @$content.find('br').addClass('removeiflast').addClass('removeiffirst');

        @$content.eq(0).columnize { 
            width: 320, 
            height: @app.$body.innerHeight()-150, 
            lastNeverTallest: true, 
            ignoreImageLoading: false,
            target: @$target,
            doneFunc: () ->
                #console.log 'column done', $(@.target).parent().find('.column:empty, p:empty')
                $(@.target).parent().find('.column:empty, p:empty').remove()
                
                $(@.target)
                    .parent()
                    .addClass 'column-ready'
                    ###
                    .find('.column:empty, p:empty')
                        .remove()
                    ###
        }

        ###
        if(@$coverImg.length > 0)
            @appendCoverImg()
        ###

    events: ->
        article = @
        @$moreButton.bind 'click', @, (e) -> 
            article = e.data 
            article.read()
            return false

        $images = $('.column-content img', @$article)
        #console.log 'found images', $images

        for $image in $images
            $("<img/>")
                .attr("src", $image.src)
                .appendTo('body')
                .load({ img: $image}, (e) ->
                    imgHeight = $(this).height()
                    imgWidth = $(this).width()

                    #console.log 'avagrund img', e.data.img, imgHeight, imgWidth, $(this).attr('src')

                    if(imgHeight > imgWidth)
                        height = imgHeight
                        height = 350 if imgHeight > 350
                        height = app.wHeight-10 if imgHeight > app.wHeight-10
                        width = parseInt(imgWidth * (height / imgHeight))
                    else
                        width = imgWidth
                        width = 650 if imgWidth > 650
                        width = app.wWidth-10 if imgWidth > app.wWidth-10
                        height = parseInt(imgHeight * (width / imgWidth))

                    $(this).remove()
                    #console.log 'avagrund popup img', height, width, (height / imgHeight)
                    
                    $('.avgrund-overlay').remove() #bugfix
                    $(e.data.img).avgrund {
                        setEvent: 'click'
                        holderClass: 'avgrundImgHolder'
                        #showClose: true
                        width: width
                        height: height
                        #overlayClass: 'overlayClass'
                        #enableStackAnimation: true
                        onLoad: () ->
                            app.setMode app.modeModal
                        onUnload: () ->
                            app.setMode app.modeRead
                        template: (img) ->
                            return  '<div class="imgHolder" style="background-image:url(' + img.attr('src') + ')">'
                    }
                )

    appendCoverImg: ->
        coverImg = $('<img>')
            .addClass('coverImg')
            .css('background-image', 'url('+@$coverImg.get(0).src+')')
            .appendTo(@$header)
        
    read: ->
        @$article.addClass('readArticle')
        @app.setMode(@app.modeRead)
        #console.log 'READ TO 0'
        #@snapview.setSnaps($('header, .column-content > .column', @$article))
        @snapview.snapIdx(0)

        setTimeout (() -> 
            #console.log 'reading ...', app, app.main
            app.main.currentArticle.snapview.setSnaps($('header, .column-content > .column', app.main.currentArticle.$article))
            #@app.main.currentArticle.snapIdx(0)
        ), 500

    unRead: ->
        @$article.removeClass('readArticle')
        @snapview.snapIdx(0)
        @app.setMode(@app.modeMain)


class Main
    constructor: (@app) ->
        #console.log 'main init'

        @scrollLock = false
        @scrollTimeout = false
        @mousewheelLock = false
        @tipTimeout = null

        @dom()
        @subs()
        @events()

        #console.log 'ready'
        #@$main.addClass 'ready'

        setTimeout (()->
            console.log 'ready'
            app.main.$main.addClass 'ready'
        ), 500


    dom: ->
        @$main = $('body > main')
        @$snaps = $('body > header, body > main > article, body > main > .pagination, body > main > footer')
        @$articles = $('body > main > article')

    subs: ->
        @snapview = new Snapview @app, @$main, @$snaps, 'top', 'offset'

        @articles = []
        for $article in @$articles 
            @articles.push(new Article @app, $($article))

    events: ->
        @snapview.onNext (idx) => app.main.onSnapChange(idx)
        @snapview.onPrev (idx) => app.main.onSnapChange(idx)

    onSnapChange: (snapIdx) ->
        @currentArticle = @articles[snapIdx-1]
        console.log 'new snap ', @currentArticle, BackgroundCheck


class App
    constructor: ->
        @modeMain = 'main'
        @modeRead = 'read'
        @modeModal = 'modal'

        @mode = @modeMain

        @wHeight = $(window).height()
        @wWidth = $(window).width()

        @dom()

        @$body.addClass 'web-app' if window.navigator.standalone


        @subs()
        @events()
        @onResize()

    dom: ->
        @$body = $('body')

    subs: ->
        @header = new Header @
        @main = new Main @

    events: ->
        @mousewheel = new Mousewheel @
        @keys = new Keys @
        @touch = new Touch @

        $(window).on 'resize', () -> app.onResize()

    onResize: ->
        @main.$main.removeClass 'ready'
        console.log 'onResize', @main.$main.get(0).classList
        
        @wHeight = $(window).height()
        @wWidth = $(window).width()

        @main.snapview.detectSnaps()
        @main.snapview.snapCurrent()

        setTimeout (()->
            console.log 'resize ready'
            app.main.$main.addClass 'ready'
        ), 500

    setMode:(@mode) ->
        @mode


$(document).ready ->
    window.app = new App