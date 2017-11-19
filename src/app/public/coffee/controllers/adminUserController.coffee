angular.module "myApp.controllers"
  .controller "AdminUserCtrl", (
    $scope
    $location
    AuthService
    ) ->
  $scope.isLoaded = false
  $scope.isAuthenticated = AuthService.status.isAuthenticated

  # ログイン済みで、別ページからの遷移
  if AuthService.status.isAuthenticated
    $scope.isLoaded = true
    return

  AuthService.isAuthenticated()
  .then (response) ->
    AuthService.status.isAuthenticated = true
    AuthService.user = response.data
    $scope.isAuthenticated = AuthService.status.isAuthenticated
    $scope.user = response.data
    $scope.isLoaded = true
  .catch (status, data) ->
    console.log status
    console.log data
    # 未ログインならログインページを表示
    $scope.isLoaded = true
    $location.path '/'
