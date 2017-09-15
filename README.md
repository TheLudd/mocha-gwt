# mocha-gwt

[![Build Status](https://travis-ci.org/TheLudd/mocha-gwt.svg)](https://travis-ci.org/TheLudd/mocha-gwt)

Given When Then for mocha

# Introduction

mocha-gwt is a proud rewrite of [mocha-given](https://github.com/rendro/mocha-given), which is a shameless port of [Justin Searls'](https://twitter.com/searls) [jasmine-given](https://github.com/searls/jasmine-given). As everyone of course knows, ```jasmine-given``` is a shameless tribute to Jim Weirichs' terrific [rspec-given](https://github.com/jimweirich/rspec-given) gem

If you are not aware of any of the mentioned projects, I recommend Justin Searl's video [Javascript Testing Tactics](https://www.youtube.com/watch?v=HHcEjAQ46Io) and the documentation to ```jasmine-given.``` In time I will most likely write documentation for this myself.

# Why yet another "given"-project?
I have been using [jasmine](http://jasmine.github.io/) and ```jasmine-given``` for a while but I found myself more and more favouring [mocha](http://mochajs.org/) over jasmine. I find mocha to be a more mature test runner and it seems to have greater performance. I was also bothered by [some](https://github.com/searls/jasmine-given/issues/25) [bugs](https://github.com/searls/jasmine-given/issues/28) in ```jasmine-given``` and [mocha-given](https://github.com/rendro/mocha-given/issues/2). Furthermore I wanted to utalize the promise support that exists in mocha. After looking at the code, and [figuring out by hand how to write mocha interfaces](https://github.com/mochajs/mocha/issues/56), I came to the conclusion that a complete re-write where I had full fredom to experiment was the best solution. I now believe that I was right.

# Differences from jasmine-given and mocha-given
 * Promise support. ```When -> Promise.resolve('foo').then (@result) =>``` will make ```@result``` available in the following ```Then```
 * Invariants will fail if you strictly return ```false``` just like ```Then``` and ```And```
 * Invariants are enough to run a test
```
describe 'myFunction', ->

  When -> @result = myFunction @input
  Invariant -> @result == ''

  describe 'should return an empty string for undefined input'
    Given -> @input = ''

  describe 'should return an empty string for null input'
    Given -> @input = null
```
 * Multiple ```Then``` functions in the same describe will act just like ```Then```, ```And```, ```And...``` I.e it will not rerun the ```Given``` and ```When``` functions that belong to the suite. This might be changed to follow the standard. But I have myself never encountered a test where non-repetition was *not* the desire.

# Usage
 1. Install: ```npm i -D mocha-gwt```
 2. Run mocha with it: ```mocha --ui mocha-gwt```
 3. To use with ```coffee-script``` do ```mocha --ui mocha-gwt --require coffee-script --compilers coffee:coffee-script/register```
