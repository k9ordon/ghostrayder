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