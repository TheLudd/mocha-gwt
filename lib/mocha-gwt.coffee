R = require 'ramda'
Mocha = require 'mocha'
Suite = Mocha.Suite
Test = Mocha.Test
Block = require './block'
descibeFunction = require './describe-function'

mochaGWT = (suite) ->
  blockList = []

  suite.on 'pre-require', (context, file, moch) ->
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

    buildMochaSuite = (block)  ->
      if block.hasTests()
        s = Suite.create suite, block.getTitle()

        block.getBefores().forEach (b) -> s.beforeAll '', b

        block.getTests().forEach (t) ->
          title = descibeFunction t
          s.addTest new Test title, ->
            val = t.apply @
            throw new Error 'Expected ' + title if val == false

    blockList.forEach buildMochaSuite

module.exports = mochaGWT
Mocha.interfaces['mocha-gwt'] = mochaGWT
