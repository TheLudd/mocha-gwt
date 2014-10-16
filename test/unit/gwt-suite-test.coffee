GwtSuite = require '../../lib/gwt-suite'

describe 'GwtSuite', ->

  beforeEach -> @subject = new GwtSuite

  it 'should instantiate', -> @subject

  describe '#addGiven', ->

    beforeEach -> @subject.addGiven()

    it 'should', ->




