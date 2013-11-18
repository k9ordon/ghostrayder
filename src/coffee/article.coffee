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

