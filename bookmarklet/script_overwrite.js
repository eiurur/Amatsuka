javascript: (function() {
  {
    var to = function(username) {
      var url = 'https://amatsuka.herokuapp.com/extract/' + username;
      window.location.href = url;
    };
    var check = function() {
      var targets = ['tweetdeck.twitter.com', 'twitter.com'];
      var hostname = location.hostname;
      if (!targets.includes(hostname)) return;
      if (hostname === 'tweetdeck.twitter.com') {
        var username = $('.prf-header .username').text();
        var superfluousText = $('.prf-header .username')
          .children()
          .text();
        var usernameNormed = username.replace(superfluousText, '');
        to(usernameNormed);
      }
      if (hostname === 'twitter.com') {
        modalExists = !!$('.permalink-tweet-container').css('display');
        if (modalExists) {
          var usernameOnModalTweet = /(@\w+)/
            .exec($('.permalink-tweet .content .username').text())[0]
            .trim();
          to(usernameOnModalTweet);
          return;
        }
        var usernameInAccountPage = $('.ProfileHeaderCard-screennameLink')
          .text()
          .trim();
        if (usernameInAccountPage) to(usernameInAccountPage);
      }
    };
    check();
  }
})();
