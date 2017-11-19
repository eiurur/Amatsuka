# Demo

![demo](https://github.com/eiurur/Amatsuka/raw/master/bookmarklet/img/redirect_to_extract_demo.gif)

# Usage

Chromeブラウザを開いて`Ctrl + d`でブックマークを登録

![](hhttps://github.com/eiurur/Amatsuka/raw/master/bookmarklet/img/chrome_2016-08-21_12-00-59.png)

ブックマーク上で右クリック -> 編集

![](hhttps://github.com/eiurur/Amatsuka/raw/master/bookmarklet/img/chrome_2016-08-21_12-01-33.png)

URLに以下のスクリプトをコピペ -> 保存

    javascript:(function(){{var to=function(username){var url="https://amatsuka.herokuapp.com/extract/"+username;window.open(url)};var check=function(){var targets=["tweetdeck.twitter.com","twitter.com"];var hostname=location.hostname;if(!targets.includes(hostname))return;if(hostname==="tweetdeck.twitter.com"){var username=$(".prf-header .username").text();var superfluousText=$(".prf-header .username").children().text();var usernameNormed=username.replace(superfluousText,"");to(usernameNormed)}if(hostname==="twitter.com"){modalExists=!!$(".permalink-tweet-container").css("display");if(modalExists){var usernameOnModalTweet=/(@\w+)/.exec($(".permalink-tweet .content .username").text())[0].trim();to(usernameOnModalTweet);return}var usernameInAccountPage=$(".ProfileHeaderCard-screennameLink").text().trim();if(usernameInAccountPage)to(usernameInAccountPage)}};check()};})();

![](hhttps://github.com/eiurur/Amatsuka/raw/master/bookmarklet/img/chrome_2016-08-21_12-02-31.png)

Twitterのユーザページ、またはツイートモーダルが開かれている状態でブックマークをクリック。

or

TweetDeckでツイートモーダル、ユーザモーダルが開かれている状態でブックマークをクリック。

![](hhttps://github.com/eiurur/Amatsuka/raw/master/bookmarklet/img/chrome_2016-08-21_12-09-41.png)

## Note

Amatsukaを新しいタブで開かず、同じタブを使って遷移したいときは以下のスクリプトをコピペして保存してください。

    javascript:(function(){{var to=function(username){var url="https://amatsuka.herokuapp.com/extract/"+username;window.location.href=url};var check=function(){var targets=["tweetdeck.twitter.com","twitter.com"];var hostname=location.hostname;if(!targets.includes(hostname))return;if(hostname==="tweetdeck.twitter.com"){var username=$(".prf-header .username").text();var superfluousText=$(".prf-header .username").children().text();var usernameNormed=username.replace(superfluousText,"");to(usernameNormed)}if(hostname==="twitter.com"){modalExists=!!$(".permalink-tweet-container").css("display");if(modalExists){var usernameOnModalTweet=/(@\w+)/.exec($(".permalink-tweet .content .username").text())[0].trim();to(usernameOnModalTweet);return}var usernameInAccountPage=$(".ProfileHeaderCard-screennameLink").text().trim();if(usernameInAccountPage)to(usernameInAccountPage)}};check()};})();

# Tool

### compiler

<a href="http://closure-compiler.appspot.com/home#code%3D%257B%250A%2520%2520const%2520to%2520%253D%2520(username)%2520%253D%253E%2520%257B%250A%2520%2520%2520%2520const%2520url%2520%253D%2520%2560https%253A%252F%252Famatsuka.herokuapp.com%252Fextract%252F%2524%257Busername%257D%2560%253B%250A%2520%2520%2520%2520window.open(url)%253B%250A%2520%2520%257D%250A%250A%2520%2520const%2520check%2520%253D%2520()%2520%253D%253E%2520%257B%250A%2520%2520%2520%2520const%2520targets%2520%253D%2520%255B%2522tweetdeck.twitter.com%2522%252C%2520%2522twitter.com%2522%255D%253B%250A%2520%2520%2520%2520const%2520hostname%2520%253D%2520location.hostname%253B%250A%250A%2520%2520%2520%2520if(!targets.includes(hostname))%2520return%253B%250A%250A%2520%2520%2520%2520if%2520(hostname%2520%253D%253D%253D%2520%2522tweetdeck.twitter.com%2522)%2520%257B%250A%2520%2520%2520%2520%2520%2520const%2520username%2520%253D%2520%2524('.mdl%2520.username').text()%253B%250A%2520%2520%2520%2520%2520%2520const%2520superfluousText%2520%253D%2520%2524('.mdl%2520.username').children().text()%253B%250A%2520%2520%2520%2520%2520%2520const%2520usernameNormed%2520%253D%2520username.replace(superfluousText%252C%2520%2522%2522)%253B%250A%2520%2520%2520%2520%2520%2520to(usernameNormed)%253B%250A%2520%2520%2520%2520%257D%250A%250A%2520%2520%2520%2520if(hostname%2520%253D%253D%253D%2520%2522twitter.com%2522)%2520%257B%250A%250A%2520%2520%2520%2520%2520%2520%252F%252F%2520%25E5%2580%258B%25E5%2588%25A5%25E3%2583%2584%25E3%2582%25A4%25E3%2583%25BC%25E3%2583%2588%250A%2520%2520%2520%2520%2520%2520const%2520usernameOnModalTweet%2520%253D%2520%2524('.Gallery-content%2520.username').text()%253B%250A%250A%2520%2520%2520%2520%2520%2520%252F%252F%2520%25E3%2582%25A2%25E3%2582%25AB%25E3%2582%25A6%25E3%2583%25B3%25E3%2583%2588%25E3%2583%259A%25E3%2583%25BC%25E3%2582%25B8%250A%2520%2520%2520%2520%2520%2520const%2520usernameInAccountPage%2520%253D%2520%2524('.ProfileHeaderCard-screennameLink').text()%253B%250A%250A%2520%2520%2520%2520%2520%2520%252F%252F%2520%250A%2520%2520%2520%2520%2520%2520if(%2524('.GalleryNav').css(%2522display%2522)%2520%253D%253D%253D%2520%2522none%2522)%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520to(usernameInAccountPage)%253B%250A%2520%2520%2520%2520%2520%2520%2520%2520return%253B%250A%2520%2520%2520%2520%2520%2520%257D%250A%250A%2520%2520%2520%2520%2520%2520if(usernameOnModalTweet%2520%257C%257C%2520usernameInAccountPage)%2520to(usernameOnModalTweet%2520%257C%257C%2520usernameInAccountPage)%253B%250A%250A%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%250A%2520%2520%257D%250A%250A%2520%2520check()%253B%250A%257D" target="_blank">Closure Compiler Service</a>