Benchmark = require 'benchmark'
intermine = require 'imjs'
{groupBy, sortBy} = require 'underscore'
require 'colors'

sum = (xs) -> xs.reduce (t, x) -> t + x

exports.run = (services, queries) ->

  suite = new Benchmark.Suite

  for args in services

    service = new intermine.Service args

    for q, i in queries then do (service, q) ->
      suite.add
        name: q.name
        service: service.root
        defer: true
        fn: (deferred) -> service.rows(q).always -> deferred.resolve()

  suite.on 'complete', ->
    groups = sortBy ({s, bms} for s, bms of groupBy @slice(), 'service'), (g) ->
      sum (bm.mean for bm in g.bms)
    for g in groups
      console.log g.s.bold.underline
      for bm in g.bms
       console.log "#{ bm.name.green }: #{ bm.stats.mean }s (rme: #{ bm.stats.rme }%)"

  suite.run async: true


