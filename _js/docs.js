// buddybuild doc JS customizations
require(['gitbook', 'jquery'], function(gitbook, $) {
  var BB_BUTTON_ID;
  var BB_PAGE = '';
  var BB_NAV_SELECTOR = '.book-summary nav ul.summary';

  gitbook.events.on('page.change', function() {
    tocInit();
    enableSyntaxHighlighting();
    makePopularDocsClickable();
    makeShowMoreClickable();
    initScroll();

    $(".book").removeClass("without-animation");
  });

  gitbook.events.bind('start', function(e, config) {
    updateToolbarButtons();
  });

  var makeCodeSamplesFancy = function () {
    $("pre.highlight").each(function () {
      $this = $(this);

      // highlight tokens in the examples, syntax= :token:
      var code = $("code", $this);
      code.html(fancyTokens(code.html()));

      // Add a copy button to all 'copyme' source examples
      if ($this.parent().parent().hasClass("copyme")) {
        var button = $('<button class="copy-to-clipboard">Copy</button>');
        $this.prepend(button);
      }
    });

    var clipboard = new Clipboard('.copy-to-clipboard', {
      target: function(trigger) {
        return trigger.nextElementSibling;
      }
    });
  };

  var enableSyntaxHighlighting = function () {
    $('pre code').each(function(i, block) {
      hljs.highlightBlock(block);
    });
  };

  var makePopularDocsClickable = function () {
    $(".popular-doc").on("click", function (e) {
      if (event.target == this) {
        window.location = $(this).find("a").attr("href");
        return false;
      }
    });
  };

  var makeShowMoreClickable = function () {
    $(".show-more a").on("click", function (e) {
      e.preventDefault();
      var elem = $(".show-more-extra");
      var $this = $(this);
      if (elem.is(":visible")) {
        elem.hide();
        $this.text("Show More");
      }
      else {
        elem.show();
        $this.text("Show Fewer");
      }
      return false;
    });
  };

  var tocInit = function () {
    // add click handler on all top-level nav elements to
    // expand/collapse their nested sub-topics.
    $(BB_NAV_SELECTOR)
      .children("li.chapter")
      .on("click", function (e) {
        tocToggle($(this));
      });

    // mark all top-level entries as candidates for collapse
    $(BB_NAV_SELECTOR)
      .children("li.chapter")
      .addClass("collapse-me");

    // expand current entry, if any
    var activeChapter = tocParent($(".chapter.active"));
    activeChapter.removeClass("collapse-me");
    tocExpand(activeChapter);

    // collapse all non-active top-level entries
    $(BB_NAV_SELECTOR)
      .children("li.chapter.collapse-me")
      .removeClass("collapse-me")
      .removeClass("expanded");
  };

  var tocToggle = function ($elem) {
    if ($elem.hasClass("expanded")) {
      tocCollapse($elem);
    }
    else {
      tocExpand($elem);
    }
  };

  var tocExpand = function ($elem) {
    if ($elem.length) {
      $elem.addClass("expanded");
    }
  };

  var tocCollapse = function ($elem) {
    if ($elem.length) {
      $elem.removeClass("expanded");
    }
  };

  // finds the top-most parent TOC item for the specified element.
  var tocParent = function ($elem) {
    if ($elem.length) {
      var p = $elem.parents("li.chapter").last();
      if (p && p.length) return p;
    }
    return $elem;
  }

  var getBBPage = function () {
    return gitbook.state.page.title
           + gitbook.state.page.level
           + gitbook.state.page.depth;
  }

  var initScroll = function () {
    var headerOffset = 100;
    if (window.location.hash && window.location.hash.length) {
      var hash = window.location.hash.split("#")[1];
      var offset = findScrollOffset(hash);
      if (offset > headerOffset) offset -= headerOffset;
      if (offset >= 0) {
        $("html,body").animate({
          scrollTop: Math.floor(offset)
        }, 300);
      }
    }
    else {
      // Make sure that we scroll to the top of each new page.
      if (BB_PAGE != '') {
        var curPage = getBBPage();
        if (BB_PAGE != curPage) {
          window.scrollTo(0, 0);
        }
      }
      BB_PAGE = getBBPage();
    }
  };

  var findScrollOffset = function (hash) {
    if (hash === undefined || hash.length == 0) return 0;

    var target;

    switch (hash[0]) {
      case 'S':
        // Scroll to this percentage down the page
        var pct = Math.floor(hash.split("S")[1]);
        if (pct >= 0) {
          return Math.floor( $(".book-body").height() * pct / 100);
        }
        return defaultScroll(hash);
        break;

      case 'P':
        // Scroll to the nth "paragraph" on the page
        var par = Math.floor(hash.split("P")[1]);
        if (par > 0) {
          target = $("p, dt, dd, pre, td, th, li", ".book .page-inner");
          if (target !== undefined
            && target.length
            && target[par - 1] !== undefined
          ) {
            return $(target[par - 1]).offset().top;
          }
        }
        return defaultScroll(hash);
        break;

      case '/':
        // Scroll to the nth paragraph on the page
        var term = decodeURIComponent(hash.split("/")[1]);
        if (term !== undefined && term.length) {
          target = $(".book .page-inner .search-noresults *:contains('"+ term +"'):last");
          if (target !== undefined && target.length) {
            return $(target[0]).offset().top;
          }
        }
        return defaultScroll(hash);
        break;

      default:
        return defaultScroll(hash);
    }

    return 0;
  };

  var defaultScroll = function (hash) {
    if (document.getElementById(hash) !== null) {
      var target = $('#' + hash.replace(/\./g, "\\."));
      if (target !== undefined && target.length) {
        return target.offset().top;
      }
    }
    return 0;
  };

  function updateToolbarButtons() {
    if (!!BB_BUTTON_ID) {
      gitbook.toolbar.removeButton(BB_BUTTON_ID);
    }

    BB_BUTTON_ID = gitbook.toolbar.createButton({
      icon: 'fa fa-chevron-down',
      label: 'buddybuild links',
      className: 'bblinks',
      position: 'right',
      index: 0,
      dropdown: [
        [
          {
            text: 'buddybuild home',
            onClick: function(e) {
              e.preventDefault();
              window.open('https://www.buddybuild.com/');
            }
          }
        ],
        [
          {
            text: 'Docs',
            className: 'active'
          }
        ],
        [
          {
            text: 'Discussion Forum',
            onClick: function(e) {
              e.preventDefault();
              window.open('https://discuss.buddybuild.com/');
            }
          }
        ],
        [
          {
            text: 'Dashboard',
            onClick: function(e) {
              e.preventDefault();
              window.open('https://dashboard.buddybuild.com/');
            }
          }
        ],
        [
          {
            text: '',
            className: 'fa fa-facebook',
            onClick: function(e) {
              e.preventDefault();
              window.open('http://www.facebook.com/sharer/sharer.php?s=100&p[url]='+encodeURIComponent(location.href));
            }
          },
          {
            text: '',
            className: 'fa fa-twitter',
            onClick: function(e) {
              e.preventDefault();
              window.open('http://twitter.com/home?status='+encodeURIComponent(document.title+' '+location.href));
            }
          },
          {
            text: '',
            className: 'fa fa-google-plus',
            onClick: function(e) {
              e.preventDefault();
              window.open('https://plus.google.com/share?url='+encodeURIComponent(location.href));
            }
          }
        ]
      ]
    });
  }
});
