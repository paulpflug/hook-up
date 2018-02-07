chai = require "chai"
should = chai.should()
hookUp = require "../src/hook-up.coffee"
obj = {
  test: 3
}
describe "hook-up", =>
  it "should work", =>
    hookUp obj, ["action1","action2"]
    test = 0
    obj.action1.hookIn (o) ->
      test = o.test + @test
    await obj.action1({test:2})
    test.should.equal 5

  it "should work async", =>
    hookUp obj, actions: "action"
    test = 0
    obj.action.hookIn => test++
    obj.action.hookIn => test++
    obj.action.hookIn => test++
    await obj.action()
    test.should.equal 3

  it "should work with custom names", =>
    hookUp obj,
      actions: "action"
      names:
        hookIn: ""
        call:"call"
    test = 0
    obj.action => test++
    await obj.action.call()
    test.should.equal 1
    hookUp obj, 
      actions: "action"
      names:
        hookIn: "reg"
    test = 0
    obj.action.reg => test++
    await obj.action()
    test.should.equal 1

  it "should work with prefix", =>
    hookUp obj,
      actions: 
       before: "action"
    test = 0
    obj.before.action.hookIn => test++
    await obj.before.action()
    test.should.equal 1

  it "should catch", (done) =>
    hookUp obj,
      actions: "action"
      catch: =>
        done()
        return
    obj.action.hookIn => throw new Error()
    obj.action()
    return 