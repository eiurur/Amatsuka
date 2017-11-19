{
  const to = username => {
    const url = `https://amatsuka.herokuapp.com/extract/${username}`;
    window.open(url);
  };

  const check = () => {
    const targets = ['tweetdeck.twitter.com', 'twitter.com'];
    const hostname = location.hostname;

    if (!targets.includes(hostname)) return;

    if (hostname === 'tweetdeck.twitter.com') {
      const username = $('.prf-header .username').text();
      const superfluousText = $('.prf-header .username')
        .children()
        .text();
      const usernameNormed = username.replace(superfluousText, '');
      to(usernameNormed);
    }

    if (hostname === 'twitter.com') {
      // 個別ツイート
      modalExists = !!$('.permalink-tweet-container').css('display');
      if (modalExists) {
        const usernameOnModalTweet = /(@\w+)/
          .exec($('.permalink-tweet .content .username').text())[0]
          .trim();
        to(usernameOnModalTweet);
        return;
      }

      const usernameInAccountPage = $('.ProfileHeaderCard-screennameLink')
        .text()
        .trim();
      // アカウントページ
      if (usernameInAccountPage) {
        to(usernameInAccountPage);
      }
    }
  };

  check();
}
