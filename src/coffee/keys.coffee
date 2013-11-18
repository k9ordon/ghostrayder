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

