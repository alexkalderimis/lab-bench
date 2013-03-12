Benchmark = require 'benchmark'
intermine = require 'imjs'
{groupBy, sortBy} = require 'underscore'
printf    = require 'printf'
require 'colors'

sum = (xs) -> xs.reduce (t, x) -> t + x
good = -> process.stdout.write '.'.green
bad  = -> process.stdout.write '.'.red

resFmt = "%-40s %6d rows; n = %3d, %02.3f secs (%.2f%% variance)"
summaryFmt = "Sum of means:".blue + " %2.3f\n"

printRes = ->
  console.log "\n COMPLETE \n--------"
  groups = sortBy ({s, bms} for s, bms of groupBy @slice(), 'service'), (g) ->
    sum (bm.stats.mean for bm in g.bms)
  for g, i in groups
    color = switch i
      when 0 then 'green'
      when groups.length - 1 then 'red'
      else 'yellow'

    console.log g.s.bold[color]
    for bm in g.bms
      {name, rowCount, stats: {mean, rme, sample: {length}}} = bm
      console.log printf resFmt, name.blue, rowCount, length, mean, rme
    console.log printf summaryFmt, sum (b.stats.mean for b in g.bms)

exports.run = (services, queries) ->

  suite = new Benchmark.Suite

  for args in services

    service = new intermine.Service args

    for q, i in queries then do (s = service, q) ->
      bm = new Benchmark
        minSamples: 50
        name: q.name
        service: s.root
        defer: true
        fn: (deferred) ->
          s.rows(q).done((rs) -> bm.rowCount = rs.length)
                   .done(good).fail(bad).always -> deferred.resolve()

      suite.push bm

  suite.on 'error', console.error

  suite.on 'complete', printRes

  suite.run async: true


