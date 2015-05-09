assert = require 'power-assert'

describe 'array', ->
  beforeEach ->
    @arr = [1, 2, 3]
  describe '#indexOf()', ->
    it 'should return index when the value is present', ->
      zero = 0
      two = 2
      assert @arr.indexOf(zero) isnt two
    it 'should ', ->
      zero = 0
      one = 1
      assert @arr.indexOf(one) is zero