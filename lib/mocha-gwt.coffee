AssertionError = require 'assertion-error'
R = require 'ramda'
Mocha = require 'mocha'
Suite = Mocha.Suite
Test = Mocha.Test
Block = require './block'
descibeFunction = require './describe-function'

comparisonRegExp = new RegExp('===|==|!==|!=|<|<=|>|>=')

wrapString = R.curry (wrapIn, string) -> wrapIn + string + wrapIn
wrapIfString = R.ifElse R.is(String), wrapString("'"), R.identity

mochaGWT = (suite) ->
  blockList = {}
  processedFiles = []
  onlyFound = false
  beforeAlls = {}
  afterAlls = {}
  fileParents = {}

  determineSkip = (block) ->
    block.pending == true || (onlyFound && !block.only)

  suite.on 'pre-require', (context, file, mocha) ->
    depth = 0
    context.currentBlock = null
    lastAtDepth = {}
    blockList[file] = []
    beforeAlls[file] = []
    afterAlls[file] = []

    addBlock = (title, fn, opts) ->
      ++depth

      parent = lastAtDepth[depth - 1]
      context.currentBlock = new Block parent, title, opts

      lastAtDepth[depth] = context.currentBlock
      blockList[file].push currentBlock

      fn.apply(@)
      context.currentBlock = lastAtDepth[--depth]

    context.describe =
    context.context = addBlock

    context.describe.skip =
    context.xdescribe =
    context.context.skip =
    context.xcontext = (title, fn) ->
      addBlock title, fn, pending: true

    context.describe.only =
    context.ddescribe =
    context.context.only =
    context.ccontext = (title, fn) ->
      addBlock title, fn, only: true
      onlyFound = true

    context.Given = (fn) -> context.currentBlock.givens.push fn
    context.When = (fn) -> context.currentBlock.whens.push fn
    context.Then = (fn) -> context.currentBlock.thens.push fn
    context.And = (fn) -> context.currentBlock.ands.push fn
    context.Invariant = (fn) -> context.currentBlock.invariants.push fn
    context.beforeAll = (fn) -> beforeAlls[file].push fn
    context.afterAll = (fn) -> afterAlls[file].push fn

    context.afterBlock = (fn) -> context.currentBlock.afterBlocks.push fn

  suite.on 'post-require', (context, file, mocha) ->
    processedFiles.push file
    fileParents[file] = Suite.create suite, ''

    buildMochaSuite = (block, file)  ->
      fileParent = fileParents[file]

      if block.hasTests()
        shouldSkip = determineSkip block

        s = Suite.create fileParent, block.getTitle()
        block.getBefores().forEach (b) -> s.beforeAll '', b unless shouldSkip

        block.getTests().concat(block.getAfterBlocks()).forEach (t) ->
          title = 'then ' + descibeFunction t
          test = new Test title, ->
            try
              val = t.apply @
            catch e
              throw e

            if val == false
              description = descibeFunction t, @
              errorMessage = 'Expected ' + description
              parts = description.split comparisonRegExp
              if isEqualityTest = parts.length == 2
                actual = parts[0].trim()
                expected = parts[1].trim()

              Error.captureStackTrace = false
              throw new AssertionError 'Expected ' + errorMessage,
                actual: wrapIfString actual
                expected: expected
                showDiff: isEqualityTest

          test.pending = shouldSkip
          s.addTest test

    if processedFiles.length == mocha.files.length
      processedFiles.forEach (f) ->
        blockList[f].forEach (block) ->
          buildMochaSuite block, f

    beforeAlls[file].forEach (fn) ->
      fileParents[file].beforeAll fn unless determineSkip blockList[file][0]
    afterAlls[file].forEach (fn) ->
      fileParents[file].afterAll fn unless determineSkip blockList[file][0]


module.exports = mochaGWT
Mocha.interfaces['mocha-gwt'] = mochaGWT
