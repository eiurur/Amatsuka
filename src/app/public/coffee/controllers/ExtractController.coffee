angular.module "myApp.controllers"
  .controller "ExtractCtrl", (
    $scope
    $location
    AuthService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  $scope.execFilteringPictWithKeyword = ->
    console.log $scope.filter

    # 対象ユーザのツイートを全件取得(1)

    # 画像だけを抽出(2)

    # 画像だけのツイートから、対象キーワードを含むツイートだけを抽出(3)

    # (3)のツイートを形態素解析し、名詞とハッシュタグを抽出(4)

    # (4)の単語集を頻出順にソート(5)

    # (5)の辞書を10件だけに絞る？(6)

    # (6)の辞書を元に、(3)と同じ手順で画像ツイートを抽出(7)

    # (7)のツイートを$scopeに代入

