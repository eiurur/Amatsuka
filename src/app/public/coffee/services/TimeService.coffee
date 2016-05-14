angular.module "myApp.services"
  .service "TimeService", ->
    normalizeDate: (term, date) ->
      switch term
        when 'days' then return moment(date).format('YYYY-MM-DD')
        when 'weeks' then return moment(date).format('YYYY-MM-DD')
        when 'month' then return moment(date).date('1').format('YYYY-MM-DD')
        else return moment(date).format('YYYY-MM-DD')

    changeDate: (term, date, amount) ->
      switch term
        when 'days' then return moment(date).add(amount, 'days').format('YYYY-MM-DD')
        when 'weeks' then return moment(date).add(amount, 'weeks').format('YYYY-MM-DD')
        when 'month' then return moment(date).add(amount, 'months').date('1').format('YYYY-MM-DD')
        else return moment().format('YYYY-MM-DD')
