# Services
angular.module "myApp.services"
  .service "MutexService", ($http) ->
    set: {}
    lock: (key) -> @set[key] = true
    unlock: (key) -> @set[key] = false
    isLock: (key) -> !!@set[key]