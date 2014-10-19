R = require 'ramda'
Mocha = require 'mocha'
Suite = Mocha.Suite
Test = Mocha.Test
Block = require './block'
descibeFunction = require './describe-function'

mochaGWT = (suite) ->
  blockList = []
  processedFiles = []
  onlyFound = false

  determineSkip = (block) ->
    block.pending == true || (onlyFound && !block.only)

  suite.on 'pre-require', (context, file, mocha) ->
    depth = 0
    context.currentBlock = null
    lastAtDepth = {}

    addBlock = (title, fn, opts) ->
      ++depth

      parent = lastAtDepth[depth - 1]
      context.currentBlock = new Block parent, title, opts

      lastAtDepth[depth] = context.currentBlock
      blockList.push currentBlock

      fn.apply()
      --depth

    global.describe = addBlock

    global.describe.skip =
    global.xdescribe = (title, fn) ->
      addBlock title, fn, pending: true

    global.describe.only =
    global.ddescribe = (title, fn) ->
      addBlock title, fn, only: true
      onlyFound = true

    global.Given = (fn) -> global.currentBlock.givens.push fn
    global.When = (fn) -> global.currentBlock.whens.push fn
    global.Then = (fn) -> global.currentBlock.thens.push fn
    global.And = (fn) -> global.currentBlock.ands.push fn
    global.Invariant = (fn) -> global.currentBlock.invariants.push fn

  suite.on 'post-require', (context, file, mocha) ->
    processedFiles.push file

    if processedFiles.length == mocha.files.length
      buildMochaSuite = (block)  ->
        if block.hasTests()
          shouldSkip = determineSkip block

          s = Suite.create suite, block.getTitle()
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
