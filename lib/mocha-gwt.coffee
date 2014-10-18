R = require 'ramda'
Mocha = require 'mocha'
Suite = Mocha.Suite
Test = Mocha.Test
Block = require './block'
descibeFunction = require './describe-function'

mochaGWT = (suite) ->
  blocks = {}

  suite.on 'pre-require', (context, file, moch) ->
    blockList = blocks[file] = []

    context.depth = 0
    context.currentBlock = null
    lastAtDepth = {}

    addBlock = (title, fn, opts) ->
      ++context.depth

      parent = lastAtDepth[context.depth - 1]
      context.currentBlock = new Block parent, title, opts

      lastAtDepth[context.depth] = context.currentBlock
      blockList.push context.currentBlock

      fn.apply()
      --context.depth

    context.describe = addBlock

    context.describe.skip =
    context.xdescribe = (title, fn) -> addBlock title, fn, pending: true

    context.describe.only =
    context.ddescribe = (title, fn) -> addBlock title, fn, only: true

    context.Given = (fn) -> context.currentBlock.givens.push fn
    context.When = (fn) -> context.currentBlock.whens.push fn
    context.Then = (fn) -> context.currentBlock.thens.push fn
    context.And = (fn) -> context.currentBlock.ands.push fn
    context.Invariant = (fn) -> context.currentBlock.invariants.push fn

  suite.on 'post-require', (context, file, mocha) ->
    blockList = blocks[file]
    determineSkip = (block) ->
      block.pending == true

    buildMochaSuite = (block)  ->
      if block.hasTests()
        shouldSkip = determineSkip block

        s = Suite.create suite, block.getTitle()
        mocha.grep s.fullTitle() if block.only
        block.getBefores().forEach (b) -> s.beforeAll '', b

        block.getTests().forEach (t) ->
          title = descibeFunction t
          test = new Test title, ->
            val = t.apply @
            throw Error 'Expected ' + title if val == false
          test.pending = shouldSkip
          s.addTest test

    blockList.forEach buildMochaSuite

module.exports = mochaGWT
Mocha.interfaces['mocha-gwt'] = mochaGWT
