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
    obj.hook1.register (o) ->
      test = o.test + @test
    await obj.hook1.execute({test:2})
    test.should.equal 5
  it "should work async", =>
    hookUp(obj)
    obj.registerHooks "hook"
    test = 0
    obj.hook.register => test++
    obj.hook.register => test++
    obj.hook.register => test++
    await obj.hook.execute()
    test.should.equal 3
  it "should work with custom names", =>
    hookUp(obj, register: "", execute:"call")
    obj.registerHooks "hook"
    test = 0
    obj.hook => test++
    await obj.hook.call()
    test.should.equal 1
    hookUp(obj, register: "reg", execute:"")
    obj.registerHooks "hook"
    test = 0
    obj.hook.reg => test++
    await obj.hook()
    test.should.equal 1
  it "should work with prefix", =>
    hookUp(obj, register: "call", execute:"", prefix:"before")
    obj.registerHooks "hook"
    test = 0
    obj.before.hook.call => test++
    await obj.before.hook()
    test.should.equal 1