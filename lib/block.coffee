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
    givens = if @parent? then @parent.givens else []
    whens = if @parent? then @parent.whens else []
    givens.concat @givens, whens, @whens

  getInvariants: ->
    if @parent? then @invariants.concat @parent.getInvariants() else @invariants

  hasTests: -> @thens.concat(@ands, @getInvariants()).length != 0

  getTests: ->
    tests = @tests.concat @ands, @invariants
    tests.concat @parent.getInvariants() if @parent?

  createMochaSuite: (mainSuite) ->
    s = Suite.create mainSuite, @title
    @getBefores().forEach (b) -> s.beforeAll '', b
    @getTests().forEach (t) -> s.addTest new Test '', t
    return s
