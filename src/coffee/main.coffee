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

