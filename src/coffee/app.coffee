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