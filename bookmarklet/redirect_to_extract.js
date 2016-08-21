{
  const to = (username) => {
    const url = `https://amatsuka.herokuapp.com/extract/${username}`;
    window.open(url);
  }

  const check = () => {
    const targets = ["tweetdeck.twitter.com", "twitter.com"];
    const hostname = location.hostname;

    if(!targets.includes(hostname)) return;

    if (hostname === "tweetdeck.twitter.com") {
      const username = $('.mdl .username').text();
      const superfluousText = $('.mdl .username').children().text();
      const usernameNormed = username.replace(superfluousText, "");
      to(usernameNormed);
    }

    if(hostname === "twitter.com") {

      // 個別ツイート
      const usernameOnModalTweet = $('.Gallery-content .username').text();

      // アカウントページ
      const usernameInAccountPage = $('.ProfileHeaderCard-screennameLink').text();

      //
      if($('.GalleryNav').css("display") === "none") {
        to(usernameInAccountPage);
        return;
      }

      if(usernameOnModalTweet || usernameInAccountPage) to(usernameOnModalTweet || usernameInAccountPage);

    }

  }

  check();
}