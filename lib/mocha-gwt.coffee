R = require 'ramda'
Mocha = require 'mocha'
Suite     = Mocha.Suite
Context   = Mocha.Context
Test      = Mocha.Test

class Waterfall

  constructor: (parent, @title) ->
    @givens = []
    @whens = []
    @tests = []
    @invariants = []

    if parent?
      @givens = parent.givens.concat []
      @whens = parent.whens.concat []
      @invariants = parent.invariants.concat []

  addGiven: (fn) -> @givens.push fn
  addWhen: (fn) -> @whens.push fn
  addThen: (fn) -> @tests.push fn
  addAnd: (fn) -> @tests.push fn
  addInvariant: (fn) -> @invariants.push fn

  _getBefores: -> @givens.concat @whens
  _getTests: -> @tests.concat @invariants

  createMochaSuite: (mainSuite) ->
    s = Suite.create mainSuite, @title
    @_getBefores().forEach (b) -> s.beforeAll '', b
    @_getTests().forEach (t) -> s.addTest new Test '', t
    return s

class GWTSuite

  constructor: ->
    @addedIndexes = []
    @waterfalls = []
    @latest = new Waterfall()

  addWaterfall: (parent, title) ->
    @latest = new Waterfall(parent, title)
    @waterfalls.push @latest

  addGiven: (fn, gwtIndex, context) ->
    unless R.contains @addedIndexes, gwtIndex
      @addWaterfall @waterfalls[gwtIndex - 1], gwtIndex
      @addedIndexes.push gwtIndex
    @latest.addGiven(fn)

  addWhen: (fn, gwtIndex) ->
    @latest.addWhen(fn)

  addThen: (fn) -> @latest.addThen fn
  addAnd: (fn) -> @latest.addAnd fn
  addInvariant: (fn) -> @latest.addInvariant fn

  getWaterfalls: -> @waterfalls

mochaGWT = (suite) ->
  gwtIndex = 0
  gwt = new GWTSuite()

  suite.on 'pre-require', (context, file, moch) ->
    rootDescribe = null

    suite.ctx = new Context

    context.describe = (title, fn) ->
      @__gwtIndex = gwtIndex++
      fn.apply null

    context.Given = (fn) ->
      gwt.addGiven fn, @__gwtIndex

    context.When = (fn) ->
      gwt.addWhen fn, @__gwtIndex

    context.Then = (fn) ->
      gwt.addThen fn

    context.And = (fn) ->
      gwt.addAnd fn

    context.Invariant = (fn) ->
      gwt.addInvariant fn

  suite.on 'post-require', (context, file, mocha) ->
    gwt.getWaterfalls().forEach (w) -> w.createMochaSuite suite

module.exports = mochaGWT
Mocha.interfaces['mocha-gwt'] = mochaGWT
