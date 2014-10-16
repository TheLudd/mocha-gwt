R = require 'ramda'
Mocha = require 'mocha'
Suite     = Mocha.Suite
Context   = Mocha.Context
Test      = Mocha.Test

class Waterfall

  constructor: (parent, @title) ->
    @givens = if parent? then parent.givens else []
    @whens = if parent? then parent.whens else []
    @invariants = if parent? then parent.invariants else []
    @tests = []

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

  needNewWaterfall: (gwtIndex) ->
    !R.contains @addedIndexes, gwtIndex

  newIsFlowNeededForSetup: (current, parent) ->
    current.hasNotCreated() && parent.hasTests() && current.hasTests()

  newFlowIsNeededForTest: (current) -> current.hasNotCreated() && parent.hasTests()

  addGiven: (fn, gwtIndex) ->
    if @needNewWaterfall gwtIndex
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

    context.depth = 0
    context.currentDescribe = null
    context.parentDescribe = null

    context.describe = (title, fn) ->
      context.depth++
      pT = if context.currentParent then currentParent.title else ''
      console.log title, pT

      context.lastDescibe =
        parent: context.currentParent
        title: title
        depth: context.depth

      context.currentDescribe =
        parent: context.currentParent
        title: title
        depth: context.depth

      context.currentParent = context.currentDescribe
      @__gwtIndex = gwtIndex++
      fn.apply()
      context.currentDescribe = context.currentParent
      context.depth--

    context.Given = (fn) ->
      gwt.addGiven fn, @__gwtIndex, context.currentDescribe

    context.When = (fn) ->
      gwt.addWhen fn, @__gwtIndex, context.currentDescribe

    context.Then = (fn) ->
      gwt.addThen fn, context.currentDescribe

    context.And = (fn) ->
      gwt.addAnd fn, context.currentDescribe

    context.Invariant = (fn) ->
      gwt.addInvariant fn, context.currentDescribe

  suite.on 'post-require', (context, file, mocha) ->
    gwt.getWaterfalls().forEach (w) -> w.createMochaSuite suite

module.exports = mochaGWT
Mocha.interfaces['mocha-gwt'] = mochaGWT
