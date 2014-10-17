chai = require 'chai'
chai.should()
R = require 'ramda'
Mocha = require 'mocha'
Suite = Mocha.Suite
Test = Mocha.Test

module.exports =

class Block

  constructor: (@parent, @title) ->
    @givens = []
    @whens = []
    @thens = []
    @ands = []
    @invariants = []

  getTitle: ->
    parentTitle = @parent.getTitle() if @parent?
    [ parentTitle, @title ].join(' ').trim()

  getBefores: ->
    givens = if @parent? then @parent.getAllGivens() else []
    whens = if @parent? then @parent.getAllWhens() else []
    givens.concat @givens, whens, @whens

  getAllGivens: ->
    parents = if @parent? then @parent.getAllGivens() else []
    parents.concat @givens

  getAllWhens: ->
    parents = if @parent? then @parent.getAllWhens() else []
    parents.concat @whens

  getInvariants: ->
    if @parent? then @invariants.concat @parent.getInvariants() else @invariants

  hasTests: -> @thens.concat(@ands, @getInvariants()).length != 0

  getTests: -> @thens.concat @ands, @getInvariants()

  buildMochaSuite: (mainSuite) ->
    regex = /.*\n/g
    end = /;$/
    start = /^return /

    replace = R.curry (regex, replacement, str) -> str.replace regex, replacement

    chopSemicolon = replace end, ''
    chopReturn = replace start, ''
    getLastStatement = R.compose chopReturn, chopSemicolon, R.trim, R.last, R.match regex

    if @hasTests()
      s = Suite.create mainSuite, @getTitle()
      @getBefores().forEach (b) -> s.beforeAll '', b
      @getTests().forEach (t) ->
        statement = getLastStatement t.toString()
        s.addTest new Test statement, ->
          val = t.apply @
          throw new Error 'Expected ' + statement if val == false
