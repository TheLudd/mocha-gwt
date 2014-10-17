R = require 'ramda'
Mocha = require 'mocha'
Suite     = Mocha.Suite
Context   = Mocha.Context
Test      = Mocha.Test

class Block

  constructor: (@parent, @title) ->
    @givens = @whens = @thens = @ands = @invariants = []

  getTitle: ->
    parentTitle = @parent.getTitle() if @parent?
    [ parentTitle, @title ].join ' '

  getBefores: ->
    befores = if @parent? then @parent.getBefores() else []
    befores.concat @givens, @whens

  hasTests: -> @thens.concat(@ands, @invariants).length != 0

  getTests: ->
    tests = @tests.concat @ands, @invariants
    tests.concat @parent.getInvariants() if @parent?

  createMochaSuite: (mainSuite) ->
    s = Suite.create mainSuite, @title
    @getBefores().forEach (b) -> s.beforeAll '', b
    @_getTests().forEach (t) -> s.addTest new Test '', t
    return s

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
  blockList = []

  suite.on 'pre-require', (context, file, moch) ->
    rootDescribe = null

    suite.ctx = new Context

    context.depth = 0
    context.currentBlock = null

    lastAtDepth = {}

    context.describe = (title, fn) ->
      ++context.depth

      parent = lastAtDepth[context.depth - 1]
      context.currentBlock = new Block parent, title

      lastAtDepth[context.depth] = context.currentBlock
      blockList.push context.currentBlock

      fn.apply()
      --context.depth

    context.Given = (fn) -> context.currentBlock.givens.push fn
    context.When = (fn) -> context.currentBlock.whens.push fn
    context.Then = (fn) -> context.currentBlock.thens.push fn
    context.And = (fn) -> context.currentBlock.ands.push fn
    context.Invariant = (fn) -> context.currentBlock.invariants.push fn

  suite.on 'post-require', (context, file, mocha) ->
    blockList.forEach (b) ->
      console.log b.getTitle()
    gwt.getWaterfalls().forEach (w) -> w.createMochaSuite suite

module.exports = mochaGWT
Mocha.interfaces['mocha-gwt'] = mochaGWT
