chai = require "chai"
should = chai.should()
hookUp = require "../src/hook-up.coffee"
obj = {
  test: 3
}
describe "hook-up", =>
  it "should work", =>
    hookUp(obj)
    obj.registerHooks ["hook1","hook2"]
    test = 0
    obj.before.hook1.call (o) ->
      test = o.test + @test
    await obj.before.hook1({test:2})
    test.should.equal 5
  it "should work async", =>
    hookUp(obj)
    obj.registerHooks "hook"
    test = 0
    obj.before.hook.call => test++
    obj.before.hook.call => test++
    obj.before.hook.call => test++
    await obj.before.hook()
    test.should.equal 3