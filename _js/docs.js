// buddybuild doc JS customizations
require(['gitbook', 'jquery'], function(gitbook, $) {

  gitbook.events.on('page.change', function() {
    BB.tocInit();
    BB.enableSyntaxHighlighting();
    BB.makePopularDocsClickable();
    BB.makeShowMoreClickable();
    BB.initEditTooltip();
    BB.initScroll();

    mediumZoom('span.frame img', {
      background: "#000",
      scrollOffset: 24
    });

    $(".book").removeClass("without-animation");
  });

  gitbook.events.bind('start', function(e, config) {
    BB.updateToolbarButtons();
  });
});
