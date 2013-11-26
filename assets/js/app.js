(function() {
  var App, Article, Header, Keys, Main, Mousewheel, Snapview, Touch;

  Touch = (function() {
    function Touch(app) {
      this.app = app;
      this.dom();
      this.events();
      this.lock = false;
      this.dragLimitX = 50;
      this.dragLimitY = 100;
    }

    Touch.prototype.dom = function() {};

    Touch.prototype.subs = function() {};

    Touch.prototype.events = function() {
      var hammertime;
      console.log('touch events');
      hammertime = $("body").hammer({
        drag_lock_to_axis: true
      });
      hammertime.on("drag", function(e) {
        return e.gesture.preventDefault();
      });
      hammertime.on("dragup dragdown", function(e) {
        return app.touch.dragY(e);
      });
      hammertime.on("dragleft dragright", function(e) {
        return app.touch.dragX(e);
      });
      hammertime.on("dragend", function(e) {
        return app.touch.dragEnd(e);
      });
      hammertime.on("swipeup", function(e) {
        return app.touch.swipeUp(e);
      });
      hammertime.on("swipedown", function(e) {
        return app.touch.swipeDown(e);
      });
      hammertime.on("swipeleft", function(e) {
        return app.touch.swipeLeft(e);
      });
      return hammertime.on("swiperight", function(e) {
        return app.touch.swipeRight(e);
      });
    };

    Touch.prototype.dragY = function(e) {
      var delta, direction;
      e.gesture.preventDefault();
      console.log('dragY', this.lock, e.gesture.direction, e.gesture.deltaY);
      if (!this.lock) {
        delta = e.gesture.deltaY;
        direction = e.gesture.direction;
        if (delta > this.dragLimitY || delta < 0 - this.dragLimitY) {
          this.lock = true;
          this.app.$body.removeClass('drag');
          if (this.app.mode === this.app.modeMain) {
            if (direction === 'up') {
              return this.app.main.snapview.snapNext();
            } else if (direction === 'down') {
              return this.app.main.snapview.snapPrev();
            }
          } else if (this.app.mode === this.app.modeRead) {
            this.app.main.currentArticle.unRead();
            return this.app.main.snapview.snapCurrent();
          }
        } else {
          console.log('draaaag');
          this.app.$body.addClass('drag');
          return this.app.main.snapview.scrollFromActive(e.gesture.deltaY, 0);
        }
      }
    };

    Touch.prototype.dragX = function(e) {
      var delta, direction;
      e.gesture.preventDefault();
      console.log('dragX', this.lock, e.gesture.direction, e.gesture.deltaX, 0 - this.dragLimitX);
      if (!this.lock) {
        delta = e.gesture.deltaX;
        direction = e.gesture.direction;
        if (delta > this.dragLimitX || delta < 0 - this.dragLimitX) {
          this.lock = true;
          this.app.$body.removeClass('drag');
          if (this.app.mode === this.app.modeMain) {
            if (direction === 'left') {
              return this.app.main.currentArticle.read();
            }
          } else if (this.app.mode === this.app.modeRead) {
            if (direction === 'left') {
              console.log('dragX next');
              return this.app.main.currentArticle.snapview.snapNext();
            } else if (direction === 'right') {
              console.log('dragX prev');
              return this.app.main.currentArticle.snapview.snapPrev();
            }
          }
        } else {
          console.log('draaaag');
          this.app.$body.addClass('drag');
          if (this.app.main.currentArticle) {
            return this.app.main.currentArticle.snapview.scrollFromActive(0, delta);
          }
        }
      }
    };

    Touch.prototype.dragEnd = function(e) {
      e.gesture.preventDefault();
      this.app.$body.removeClass('drag');
      console.log('dragEnd', e.gesture.deltaY);
      if (this.app.mode === this.app.modeMain && !this.lock) {
        this.app.main.snapview.snapCurrent();
      } else if (this.app.mode === this.app.modeRead && !this.lock) {
        this.app.main.snapview.snapCurrent();
        this.app.main.currentArticle.snapview.snapCurrent();
      }
      return this.lock = false;
    };

    Touch.prototype.swipeUp = function(e) {
      e.gesture.preventDefault();
      console.log('swipeUp', this.lock);
      if (!this.lock) {
        this.lock = true;
        if (this.app.mode === this.app.modeRead) {
          return this.app.main.currentArticle.unRead();
        } else if (this.app.mode === this.app.modeMain) {
          return this.app.main.snapview.snapNext();
        }
      }
    };

    Touch.prototype.swipeDown = function(e) {
      e.gesture.preventDefault();
      console.log('swipeDown', this.lock);
      if (!this.lock) {
        this.lock = true;
        if (this.app.mode === this.app.modeRead) {
          return this.app.main.currentArticle.unRead();
        } else if (this.app.mode === this.app.modeMain) {
          return this.app.main.snapview.snapPrev();
        }
      }
    };

    Touch.prototype.swipeLeft = function(e) {
      e.gesture.preventDefault();
      console.log('swipeLeft', this.lock);
      this.app.main.snapview.unTip();
      if (!this.lock) {
        this.lock = true;
        if (this.app.mode === this.app.modeMain) {
          return this.app.main.currentArticle.read();
        } else if (this.app.mode === this.app.modeRead) {
          console.log('swipeLeft next');
          return this.app.main.currentArticle.snapview.snapNext();
        }
      }
    };

    Touch.prototype.swipeRight = function(e) {
      e.gesture.preventDefault();
      console.log('swipeRight', this.lock);
      this.app.main.snapview.unTip();
      if (!this.lock) {
        this.lock = true;
        if (this.app.mode === this.app.modeRead) {
          console.log('swipeRight prev');
          return this.app.main.currentArticle.snapview.snapPrev();
        }
      }
    };

    return Touch;

  })();

  Mousewheel = (function() {
    function Mousewheel(app) {
      this.app = app;
      this.lock = false;
      setTimeout(function() {
        return app.mousewheel.events();
      }, 1000);
    }

    Mousewheel.prototype.events = function() {
      return $(window).bind('mousewheel', function(e, delta, deltaX, deltaY) {
        return app.mousewheel.mousewheelHandler(e, delta, deltaX, deltaY);
      });
    };

    Mousewheel.prototype.mousewheelHandler = function(e, delta, deltaX, deltaY) {
      if (delta === 1 ||  delta === -1 ||  delta === 0) {
        this.idle();
      } else if (this.lock === true) {
        this.locked();
      } else if (deltaY < -15) {
        this.downFast();
      } else if (deltaY < -1) {
        this.down();
      } else if (deltaY > 15) {
        this.upFast();
      } else if (deltaY > 1) {
        this.up();
      } else if (deltaX < -1) {
        this.rightFast();
      } else if (deltaX < -1) {
        this.right();
      } else if (deltaX > 1) {
        this.leftFast();
      } else if (deltaX > 1) {
        this.left();
      } else {
        console.log('whuuut?');
      }
      return false;
    };

    Mousewheel.prototype.idle = function() {};

    Mousewheel.prototype.locked = function() {};

    Mousewheel.prototype.down = function() {
      if (this.app.mode === this.app.modeMain) {
        return app.main.snapview.tipNext();
      }
    };

    Mousewheel.prototype.downFast = function() {
      console.log('downFast');
      this.lock = true;
      setTimeout((function() {
        return app.mousewheel.lock = false;
      }), 700);
      if (this.app.mode === this.app.modeRead) {
        return this.app.main.currentArticle.unRead();
      } else if (this.app.mode === this.app.modeMain) {
        return this.app.main.snapview.snapNext();
      }
    };

    Mousewheel.prototype.up = function() {
      if (this.app.mode === this.app.modeMain) {
        return this.app.main.snapview.tipPrev();
      }
    };

    Mousewheel.prototype.upFast = function() {
      console.log('upFast');
      this.lock = true;
      setTimeout((function() {
        return app.mousewheel.lock = false;
      }), 700);
      if (this.app.mode === this.app.modeRead) {
        return this.app.main.currentArticle.unRead();
      } else if (this.app.mode === this.app.modeMain) {
        return this.app.main.snapview.snapPrev();
      }
    };

    Mousewheel.prototype.right = function() {};

    Mousewheel.prototype.rightFast = function() {
      console.log('rightFast');
      this.lock = true;
      setTimeout((function() {
        return app.mousewheel.lock = false;
      }), 700);
      this.app.main.snapview.unTip();
      if (this.app.mode === this.app.modeRead) {
        return this.app.main.currentArticle.snapview.snapPrev();
      }
    };

    Mousewheel.prototype.left = function() {};

    Mousewheel.prototype.leftFast = function() {
      console.log('leftFast');
      this.lock = true;
      setTimeout((function() {
        return app.mousewheel.lock = false;
      }), 700);
      this.app.main.snapview.unTip();
      if (this.app.mode === this.app.modeMain) {
        return this.app.main.currentArticle.read();
      } else if (this.app.mode === this.app.modeRead) {
        return this.app.main.currentArticle.snapview.snapNext();
      }
    };

    return Mousewheel;

  })();

  Keys = (function() {
    function Keys(app) {
      this.app = app;
      this.events();
    }

    Keys.prototype.events = function() {
      $(document).bind('keydown', 'down', function(e) {
        if (app.mode === app.modeRead) {
          return app.main.currentArticle.unRead();
        } else if (app.mode === app.modeMain) {
          return app.main.snapview.snapNext();
        }
      });
      $(document).bind('keydown', 'up', function() {
        if (app.mode === app.modeRead) {
          return app.main.currentArticle.unRead();
        } else if (app.mode === app.modeMain) {
          return app.main.snapview.snapPrev();
        }
      });
      $(document).bind('keydown', 'right', function(e) {
        if (app.mode === app.modeMain) {
          return app.main.currentArticle.read();
        } else if (app.mode === app.modeRead) {
          return app.main.currentArticle.snapview.snapNext();
        }
      });
      return $(document).bind('keydown', 'left', function() {
        if (app.mode === app.modeMain) {

        } else if (app.mode === app.modeRead) {
          return app.main.currentArticle.snapview.snapPrev();
        }
      });
    };

    return Keys;

  })();

  Snapview = (function() {
    function Snapview(app, $view, $snaps, direction, offsetType) {
      this.app = app;
      this.$view = $view;
      this.$snaps = $snaps;
      this.direction = direction != null ? direction : 'top';
      this.offsetType = offsetType != null ? offsetType : 'offset';
      this.tipSize = 50;
      this.setSnaps(this.$snaps);
      this.snapIdx(0);
    }

    Snapview.prototype.setSnaps = function($snaps) {
      this.$snaps = $snaps;
      return this.detectSnaps();
    };

    Snapview.prototype.detectSnaps = function() {
      var $snap, idx, offset, snap, _i, _len, _ref, _results;
      this.snapTops = [];
      this.snapBottoms = [];
      this.snapLefts = [];
      this.snapRights = [];
      this.snapLength = 0;
      _ref = this.$snaps;
      _results = [];
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        snap = _ref[idx];
        $snap = $(snap);
        this.snapLength++;
        if (this.offsetType === 'offset') {
          offset = $snap.offset();
        } else if (this.offsetType === 'position') {
          offset = $snap.position();
        }
        this.snapTops.push(offset.top);
        this.snapBottoms.push(offset.top + $snap.height());
        this.snapLefts.push(offset.left);
        _results.push(this.snapRights.push(offset.left + $snap.width()));
      }
      return _results;
    };

    Snapview.prototype.scrollTo = function(top, left) {
      if (this.direction === 'top') {
        left = 0;
      }
      if (this.direction === 'left') {
        top = 0;
      }
      this.currentTop = 0 - parseInt(top);
      this.currentLeft = 0 - parseInt(left);
      return this.$view.css('-webkit-transform', 'translate3d(' + this.currentLeft + 'px,' + this.currentTop + 'px,0)');
    };

    Snapview.prototype.scrollFromActive = function(top, left) {
      if (this.direction === 'top') {
        left = 0;
      }
      if (this.direction === 'left') {
        top = 0;
      }
      return this.scrollTo(this.snapTops[this.activeIdx] - top, this.snapLefts[this.activeIdx] - left);
    };

    Snapview.prototype.scrollBy = function(top, left) {
      if (this.direction === 'top') {
        left = 0;
      }
      if (this.direction === 'left') {
        top = 0;
      }
      return this.scrollTo(0 - this.currentTop + top, 0 - this.currentLeft + left);
    };

    Snapview.prototype.snapIdx = function(idx) {
      this.activeIdx = idx;
      if (this.$active) {
        this.$active.removeClass('activeSnap');
      }
      this.$active = $(this.$snaps[idx]);
      this.scrollTo(this.snapTops[this.activeIdx], this.snapLefts[this.activeIdx]);
      return this.$active.addClass('activeSnap');
    };

    Snapview.prototype.tipNext = function() {
      var nextIdx;
      nextIdx = this.activeIdx + 1;
      console.log('tipNext', nextIdx, this.snapTops, this.snapLefts);
      if (nextIdx < this.snapLength) {
        this.scrollTo(this.snapTops[this.activeIdx] + this.tipSize, this.snapLefts[this.activeIdx]);
        if (this.tipTimeout) {
          clearTimeout(this.tipTimeout);
        }
        return this.tipTimeout = setTimeout((function() {
          return app.main.snapview.unTip();
        }), 1000);
      }
    };

    Snapview.prototype.tipPrev = function() {
      var prevIdx;
      prevIdx = this.activeIdx - 1;
      if (prevIdx >= 0) {
        this.scrollTo(this.snapTops[this.activeIdx] - this.tipSize, this.snapLefts[this.activeIdx]);
        if (this.tipTimeout) {
          clearTimeout(this.tipTimeout);
        }
        return this.tipTimeout = setTimeout((function() {
          return app.main.snapview.unTip();
        }), 1000);
      }
    };

    Snapview.prototype.unTip = function() {
      if (this.tipTimeout) {
        clearTimeout(this.tipTimeout);
      }
      return this.scrollTo(this.snapTops[this.activeIdx], this.snapLefts[this.activeIdx]);
    };

    Snapview.prototype.snapCurrent = function() {
      return this.snapIdx(this.activeIdx);
    };

    Snapview.prototype.snapNext = function() {
      var nextIdx;
      nextIdx = this.activeIdx + 1;
      if (nextIdx < this.snapLength) {
        this.snapIdx(nextIdx);
        if (this.callbackOnNext) {
          return this.callbackOnNext(this.activeIdx);
        }
      }
    };

    Snapview.prototype.onNext = function(callback) {
      return this.callbackOnNext = callback;
    };

    Snapview.prototype.snapPrev = function() {
      var prevIdx;
      prevIdx = this.activeIdx - 1;
      if (prevIdx >= 0) {
        this.snapIdx(prevIdx);
        if (this.callbackOnNext) {
          return this.callbackOnNext(this.activeIdx);
        }
      }
    };

    Snapview.prototype.onPrev = function(callback) {
      return this.callbackOnPrev = callback;
    };

    return Snapview;

  })();

  Header = (function() {
    function Header(app) {
      this.app = app;
      this.dom();
      this.events();
      if (this.$headerImg.length > 0) {
        if ((this.$headerImg.get(0).complete)) {
          this.headerDesign();
        } else {
          this.$headerImg.load(function() {
            return app.header.headerDesign();
          });
        }
      } else {
        this.app.$body.addClass('ready');
      }
    }

    Header.prototype.dom = function() {
      this.$header = $('body > header');
      this.$h1 = $('body > header h1');
      this.$headerCover = this.$header.find('#header-cover');
      return this.$headerImg = this.$header.find('#header-cover img');
    };

    Header.prototype.events = function() {
      return this.$h1.bind('click', function(e) {
        e.preventDefault();
        return app.main.snapview.snapIdx(0);
      });
    };

    Header.prototype.headerDesign = function() {
      var $firstNextA, $nextAs, colorThief, headerColor, headerColors;
      console.log('header design', this.$headerCover, this.app.wHeight);
      this.app.$body.removeClass('ready');
      this.$headerCover.height(this.app.wHeight);
      window.BackgroundCheck.init({
        targets: '.bc',
        threshold: 70
      });
      $nextAs = $('.next-article a');
      $firstNextA = $nextAs.eq(0);
      if ($firstNextA.is('.background--light')) {
        $nextAs.addClass('background--light');
      }
      if ($firstNextA.is('.background--dark')) {
        $nextAs.addClass('background--dark');
      }
      colorThief = new window.ColorThief();
      headerColors = colorThief.getPalette(this.$headerImg.get(0), 2);
      headerColor = colorThief.getColor(this.$headerImg.get(0));
      $("<style type='text/css'>" + "body > main > article > header .meta section.tags, " + "body > main > article > header .meta section span, " + "body > main .next-article a," + "body > main > article > .column-content a, " + "body > main > article > .column-content b " + "{ color:rgb(" + (headerColors[2].join(',')) + "); }" + "body > main > article > .more > .more-button, " + "body > main > article.column-ready > .column-content > .column:after, " + "body > main > article > header h2 a, " + "body > main > article > .column-content h2, " + "body > main > article > .column-content h3 " + "{ color:rgb(" + (headerColors[0].join(',')) + "); }" + "body > main > article > .column-content > .column, " + "body > main > article > .more > .more-button, " + "body > main > article > header " + "{ border-color:rgb(" + (headerColors[0].join(',')) + "); }" + "body " + "{ background-color:rgb(" + (headerColor.join(',')) + "); }" + "#titlebar " + "{ background-color:rgba(" + (headerColor.join(',')) + ",0.6); }" + " </style>").appendTo("head");
      /*
      @$headerCover.blurjs({
          source: 'body',
          radius: 10,
          overlay: 'rgba('+(headerColor.join(','))+',0.3)'
      });
      */

      return this.app.$body.addClass('ready');
    };

    return Header;

  })();

  Article = (function() {
    function Article(app, $article) {
      this.app = app;
      this.$article = $article;
      this.dom();
      this.createLayout();
      this.events();
      this.subs();
    }

    Article.prototype.subs = function() {
      this.$snaps = $('header, .column-content > .column', this.$article);
      return this.snapview = new Snapview(this.app, this.$target, this.$snaps, 'left', 'position');
    };

    Article.prototype.dom = function() {
      this.$header = $('header', this.$article);
      this.$coverImg = $('.content img:not([src=""])', this.$article).eq(0);
      this.$content = $('.content', this.$article);
      this.$target = $('.column-content', this.$article);
      this.$more = $('.more', this.$article);
      return this.$moreButton = $('.more-button', this.$article);
    };

    Article.prototype.createLayout = function() {
      if (this.$coverImg.length && this.$coverImg.length > 0 && this.$coverImg.get(0).src.indexOf(window.location.host) === 7) {
        this.$coverImg.load(function() {
          var articleColor, colorThief;
          colorThief = new ColorThief;
          articleColor = colorThief.getColor(this);
          return $(this.parentNode).parents('article').find('header .header-cover').css('backgroundColor', 'rgba(' + articleColor.join(',') + ',0.1)');
        });
      }
      this.$content.find('p:empty').remove();
      this.$content.find('table, thead, tbody, tfoot, colgroup, caption, label, legend, script, style, textarea, button, object, embed, tr, th, td, li, h1, h2, h3, h4, h5, h6, form').addClass('dontsplit');
      this.$content.find('h1, h2, h3, h4, h5, h6').addClass('dontend');
      this.$content.find('br').addClass('removeiflast').addClass('removeiffirst');
      return this.$content.eq(0).columnize({
        width: 320,
        height: this.app.$body.innerHeight() - 150,
        lastNeverTallest: true,
        ignoreImageLoading: false,
        target: this.$target,
        doneFunc: function() {
          $(this.target).parent().find('.column:empty, p:empty').remove();
          return $(this.target).parent().addClass('column-ready');
          /*
              .find('.column:empty, p:empty')
                  .remove()
          */

        }
      });
      /*
      if(@$coverImg.length > 0)
          @appendCoverImg()
      */

    };

    Article.prototype.events = function() {
      var $image, $images, article, _i, _len, _results;
      article = this;
      this.$moreButton.bind('click', this, function(e) {
        article = e.data;
        article.read();
        return false;
      });
      $images = $('.column-content img', this.$article);
      _results = [];
      for (_i = 0, _len = $images.length; _i < _len; _i++) {
        $image = $images[_i];
        _results.push($("<img/>").attr("src", $image.src).appendTo('body').load({
          img: $image
        }, function(e) {
          var height, imgHeight, imgWidth, width;
          imgHeight = $(this).height();
          imgWidth = $(this).width();
          if (imgHeight > imgWidth) {
            height = imgHeight;
            if (imgHeight > 350) {
              height = 350;
            }
            if (imgHeight > app.wHeight - 10) {
              height = app.wHeight - 10;
            }
            width = parseInt(imgWidth * (height / imgHeight));
          } else {
            width = imgWidth;
            if (imgWidth > 650) {
              width = 650;
            }
            if (imgWidth > app.wWidth - 10) {
              width = app.wWidth - 10;
            }
            height = parseInt(imgHeight * (width / imgWidth));
          }
          $(this).remove();
          $('.avgrund-overlay').remove();
          return $(e.data.img).avgrund({
            setEvent: 'click',
            holderClass: 'avgrundImgHolder',
            width: width,
            height: height,
            onLoad: function() {
              return app.setMode(app.modeModal);
            },
            onUnload: function() {
              return app.setMode(app.modeRead);
            },
            template: function(img) {
              return '<div class="imgHolder" style="background-image:url(' + img.attr('src') + ')">';
            }
          });
        }));
      }
      return _results;
    };

    Article.prototype.appendCoverImg = function() {
      var coverImg;
      return coverImg = $('<img>').addClass('coverImg').css('background-image', 'url(' + this.$coverImg.get(0).src + ')').appendTo(this.$header);
    };

    Article.prototype.read = function() {
      this.$article.addClass('readArticle');
      this.app.setMode(this.app.modeRead);
      this.snapview.snapIdx(0);
      return setTimeout((function() {
        return app.main.currentArticle.snapview.setSnaps($('header, .column-content > .column', app.main.currentArticle.$article));
      }), 500);
    };

    Article.prototype.unRead = function() {
      this.$article.removeClass('readArticle');
      this.snapview.snapIdx(0);
      return this.app.setMode(this.app.modeMain);
    };

    return Article;

  })();

  Main = (function() {
    function Main(app) {
      this.app = app;
      this.scrollLock = false;
      this.scrollTimeout = false;
      this.mousewheelLock = false;
      this.tipTimeout = null;
      this.dom();
      this.subs();
      this.events();
      setTimeout((function() {
        console.log('ready');
        return app.main.$main.addClass('ready');
      }), 500);
    }

    Main.prototype.dom = function() {
      this.$main = $('body > main');
      this.$snaps = $('body > header, body > main > article, body > main > .pagination, body > main > footer');
      return this.$articles = $('body > main > article');
    };

    Main.prototype.subs = function() {
      var $article, _i, _len, _ref, _results;
      this.snapview = new Snapview(this.app, this.$main, this.$snaps, 'top', 'offset');
      this.articles = [];
      _ref = this.$articles;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        $article = _ref[_i];
        _results.push(this.articles.push(new Article(this.app, $($article))));
      }
      return _results;
    };

    Main.prototype.events = function() {
      var _this = this;
      this.snapview.onNext(function(idx) {
        return app.main.onSnapChange(idx);
      });
      return this.snapview.onPrev(function(idx) {
        return app.main.onSnapChange(idx);
      });
    };

    Main.prototype.onSnapChange = function(snapIdx) {
      this.currentArticle = this.articles[snapIdx - 1];
      return console.log('new snap ', this.currentArticle, BackgroundCheck);
    };

    return Main;

  })();

  App = (function() {
    function App() {
      this.modeMain = 'main';
      this.modeRead = 'read';
      this.modeModal = 'modal';
      this.mode = this.modeMain;
      this.wHeight = $(window).height();
      this.wWidth = $(window).width();
      this.dom();
      if (window.navigator.standalone) {
        this.$body.addClass('web-app');
      }
      this.subs();
      this.events();
      this.onResize();
    }

    App.prototype.dom = function() {
      return this.$body = $('body');
    };

    App.prototype.subs = function() {
      this.header = new Header(this);
      return this.main = new Main(this);
    };

    App.prototype.events = function() {
      this.mousewheel = new Mousewheel(this);
      this.keys = new Keys(this);
      this.touch = new Touch(this);
      return $(window).on('resize', function() {
        return app.onResize();
      });
    };

    App.prototype.onResize = function() {
      this.main.$main.removeClass('ready');
      console.log('onResize', this.main.$main.get(0).classList);
      this.wHeight = $(window).height();
      this.wWidth = $(window).width();
      this.main.snapview.detectSnaps();
      this.main.snapview.snapCurrent();
      return setTimeout((function() {
        console.log('resize ready');
        return app.main.$main.addClass('ready');
      }), 500);
    };

    App.prototype.setMode = function(mode) {
      this.mode = mode;
      return this.mode;
    };

    return App;

  })();

  $(document).ready(function() {
    return window.app = new App;
  });

}).call(this);

/*
//@ sourceMappingURL=app.js.map
*/