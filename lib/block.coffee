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
    givens = if @parent? then @parent._getGivenHierarchy() else []
    whens = if @parent? then @parent._getWhenHierarchy() else []
    givens.concat @givens, whens, @whens

  _getGivenHierarchy: ->
    parents = if @parent? then @parent._getGivenHierarchy() else []
    parents.concat @givens

  _getWhenHierarchy: ->
    parents = if @parent? then @parent._getWhenHierarchy() else []
    parents.concat @whens

  getInvariants: ->
    if @parent? then @invariants.concat @parent.getInvariants() else @invariants

  hasTests: -> @thens.concat(@ands, @getInvariants()).length != 0

  getTests: -> @thens.concat @ands, @getInvariants()
