# Usage

Chromeブラウザを開いて`Ctrl + d`でブックマークを登録

![](https://dl.dropboxusercontent.com/u/31717228/ShareX/2016/08/chrome_2016-08-21_12-00-59.png)

ブックマーク上で右クリック -> 編集

![](https://dl.dropboxusercontent.com/u/31717228/ShareX/2016/08/chrome_2016-08-21_12-01-33.png)

URLに以下のスクリプトをコピペ -> 保存

    javascript:(function(){var to=function(a){window.open("https://amatsuka.herokuapp.com/extract/"+a)},check=function(){var a=location.hostname;if(["tweetdeck.twitter.com","twitter.com"].includes(a)){if("tweetdeck.twitter.com"===a){var b=$(".mdl .username").text(),c=$(".mdl .username").children().text(),b=b.replace(c,"");to(b)}"twitter.com"===a&&(a=$(".Gallery-content .username").text(),b=$(".ProfileHeaderCard-screennameLink").text(),"none"===$(".GalleryNav").css("display")?to(b):(a||b)&&to(a||b))}};check();})();

![](https://dl.dropboxusercontent.com/u/31717228/ShareX/2016/08/chrome_2016-08-21_12-02-31.png)

Twitterのユーザページ、またはツイートモーダルが開かれている状態でブックマークをクリック。

or

TweetDeckでツイートモーダル、ユーザモーダルが開かれている状態でブックマークをクリック。

![](https://dl.dropboxusercontent.com/u/31717228/ShareX/2016/08/chrome_2016-08-21_12-09-41.png)

## Note

Amatsukaを新しいタブで開かず、同じタブを使って遷移したいときは以下のスクリプトをコピペして保存してください。

    javascript:(function(){var to=function(a){window.location.href="https://amatsuka.herokuapp.com/extract/"+a},check=function(){var a=location.hostname;if(["tweetdeck.twitter.com","twitter.com"].includes(a)){if("tweetdeck.twitter.com"===a){var b=$(".mdl .username").text(),c=$(".mdl .username").children().text(),b=b.replace(c,"");to(b)}"twitter.com"===a&&(a=$(".Gallery-content .username").text(),b=$(".ProfileHeaderCard-screennameLink").text(),"none"===$(".GalleryNav").css("display")?to(b):(a||b)&&to(a||b))}};check();})();

# Tool

### compiler

<a href="http://closure-compiler.appspot.com/home#code%3D%257B%250A%2520%2520const%2520to%2520%253D%2520(username)%2520%253D%253E%2520%257B%250A%2520%2520%2520%2520const%2520url%2520%253D%2520%2560https%253A%252F%252Famatsuka.herokuapp.com%252Fextract%252F%2524%257Busername%257D%2560%253B%250A%2520%2520%2520%2520window.open(url)%253B%250A%2520%2520%257D%250A%250A%2520%2520const%2520check%2520%253D%2520()%2520%253D%253E%2520%257B%250A%2520%2520%2520%2520const%2520targets%2520%253D%2520%255B%2522tweetdeck.twitter.com%2522%252C%2520%2522twitter.com%2522%255D%253B%250A%2520%2520%2520%2520const%2520hostname%2520%253D%2520location.hostname%253B%250A%250A%2520%2520%2520%2520if(!targets.includes(hostname))%2520return%253B%250A%250A%2520%2520%2520%2520if%2520(hostname%2520%253D%253D%253D%2520%2522tweetdeck.twitter.com%2522)%2520%257B%250A%2520%2520%2520%2520%2520%2520const%2520username%2520%253D%2520%2524('.mdl%2520.username').text()%253B%250A%2520%2520%2520%2520%2520%2520const%2520superfluousText%2520%253D%2520%2524('.mdl%2520.username').children().text()%253B%250A%2520%2520%2520%2520%2520%2520const%2520usernameNormed%2520%253D%2520username.replace(superfluousText%252C%2520%2522%2522)%253B%250A%2520%2520%2520%2520%2520%2520to(usernameNormed)%253B%250A%2520%2520%2520%2520%257D%250A%250A%2520%2520%2520%2520if(hostname%2520%253D%253D%253D%2520%2522twitter.com%2522)%2520%257B%250A%250A%2520%2520%2520%2520%2520%2520%252F%252F%2520%25E5%2580%258B%25E5%2588%25A5%25E3%2583%2584%25E3%2582%25A4%25E3%2583%25BC%25E3%2583%2588%250A%2520%2520%2520%2520%2520%2520const%2520usernameOnModalTweet%2520%253D%2520%2524('.Gallery-content%2520.username').text()%253B%250A%250A%2520%2520%2520%2520%2520%2520%252F%252F%2520%25E3%2582%25A2%25E3%2582%25AB%25E3%2582%25A6%25E3%2583%25B3%25E3%2583%2588%25E3%2583%259A%25E3%2583%25BC%25E3%2582%25B8%250A%2520%2520%2520%2520%2520%2520const%2520usernameInAccountPage%2520%253D%2520%2524('.ProfileHeaderCard-screennameLink').text()%253B%250A%250A%2520%2520%2520%2520%2520%2520%252F%252F%2520%250A%2520%2520%2520%2520%2520%2520if(%2524('.GalleryNav').css(%2522display%2522)%2520%253D%253D%253D%2520%2522none%2522)%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520to(usernameInAccountPage)%253B%250A%2520%2520%2520%2520%2520%2520%2520%2520return%253B%250A%2520%2520%2520%2520%2520%2520%257D%250A%250A%2520%2520%2520%2520%2520%2520if(usernameOnModalTweet%2520%257C%257C%2520usernameInAccountPage)%2520to(usernameOnModalTweet%2520%257C%257C%2520usernameInAccountPage)%253B%250A%250A%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%250A%2520%2520%257D%250A%250A%2520%2520check()%253B%250A%257D" target="_blank">Closure Compiler Service</a>