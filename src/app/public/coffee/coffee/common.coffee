###
Logの拡張
###
methods = [
  "log"
  "warn"
  "error"
  "info"
  "debug"
  "dir"
]
for i of methods
  ((m) ->
    if console[m]
      window[m] = console[m].bind(console)
    else
      window[m] = log
    return
  ) methods[i]
# log "hoge"
# warn "fuga"
# error "piyo"
# info "nyan"
# debug "wan"