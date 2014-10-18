chai = require 'chai'
chai.should()
Block = require '../../lib/block'

describe 'Block', ->

  it 'should instantiate', -> new Block()

  it 'should set a simple title', ->
    block = new Block undefined, 'my title'
    block.getTitle().should.equal 'my title'

  it 'should concatenate parents titles', ->
    parent = new Block undefined, 'first block'
    child = new Block parent, 'second block'
    child.getTitle().should.equal 'first block second block'

  it 'should return things added as givens as befores', ->
    block = new Block()
    block.givens.push 1
    block.getBefores().should.deep.equal [ 1 ]

  it 'should return several things added as givens as befores', ->
    block = new Block()
    block.givens.push 1
    block.givens.push 2
    block.getBefores().should.deep.equal [ 1, 2 ]

  it 'should return things added as whens as befores', ->
    block = new Block()
    block.whens.push 1
    block.whens.push 2
    block.getBefores().should.deep.equal [ 1, 2 ]

  it 'should return a combination of givens and whens with givens first', ->
    block = new Block()
    block.whens.push 1
    block.givens.push 2
    block.getBefores().should.deep.equal [ 2, 1 ]

  it 'should return parents givens and whens in the correct order', ->
    parent = new Block()
    parent.whens.push 1
    parent.givens.push 2
    child = new Block(parent)
    child.whens.push 3
    child.givens.push 4
    child.getBefores().should.deep.equal [ 2, 4, 1, 3 ]

  it 'should return parents givens and whens in many steps', ->
    top = new Block()
    top.givens.push 'a'
    top.whens.push 'b'
    parent = new Block(top)
    parent.whens.push 1
    parent.givens.push 2
    child = new Block(parent)
    child.whens.push 3
    child.givens.push 4
    child.getBefores().should.deep.equal [ 'a', 2, 4, 'b', 1, 3 ]

  it 'should return false for hasTests if there are no tests', ->
    new Block().hasTests().should.not.be.ok

  it 'should return true for hasTests if there are tests', ->
    block = new Block()
    block.thens.push 1
    block.hasTests().should.be.ok

  it 'should return true for hasTests if parent has invariants', ->
    parent = new Block()
    parent.invariants.push 1
    child = new Block(parent)
    child.hasTests().should.be.ok

  it 'should return an empty array for getInvariants if there are none', ->
    block = new Block()
    block.getInvariants().should.deep.equal []

  it 'should return the blocks own invariants', ->
    block = new Block()
    block.invariants.push 1
    block.getInvariants().should.deep.equal [ 1 ]

  it 'should return a combination of the parents invariants and its own', ->
    parent = new Block()
    parent.invariants.push 1
    child = new Block(parent)
    child.invariants.push 2
    child.getInvariants().should.deep.equal [ 2, 1 ]

  it 'should return the tests from calls to getTests', ->
    block = new Block()
    block.thens.push 1
    block.getTests().should.deep.equal [ 1 ]

  it 'should return thens and ands concatenated from calls to getTests', ->
    block = new Block()
    block.thens.push 1
    block.ands.push 2
    block.getTests().should.deep.equal [ 1, 2 ]

  it 'should return thens ands and invarianst from calls to getTests', ->
    block = new Block()
    block.thens.push 1
    block.ands.push 2
    block.invariants.push 3
    block.getTests().should.deep.equal [ 1, 2, 3 ]

  it 'should return thens ands and parents invariants from cllas to getTests', ->
    parent = new Block()
    parent.invariants.push 0
    child = new Block(parent)
    child.thens.push 1
    child.ands.push 2
    child.invariants.push 3
    child.getTests().should.deep.equal [ 1, 2, 3, 0 ]

  it 'should be pending if parent is pending', ->
    parent = new Block null, null, pending: true
    child = new Block parent
    child.pending.should.be.ok

  it 'inherit parents only', ->
    parent = new Block null, null, only: true
    child = new Block parent
    child.only.should.be.ok
