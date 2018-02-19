{test} = require "snapy"
hookUp = require "../src/hook-up.coffee"
obj = {
  test: 3
}
test (snap) =>
  hookUp obj, ["action1","action2"]
  obj.action1.hookIn (o, _obj) -> 
    o.test += @test + _obj.test
  # result 8
  snap promise: obj.action1({test:2})
  adder = (o) => o.test++
  obj.action2.hookIn adder
  obj.action2.hookIn adder
  obj.action2.hookIn adder
  # result 3
  snap promise: obj.action2(test:0)
  hookUp obj,
    actions: "action"
    names:
      hookIn: ""
      call:"call"
  obj.action (o) => o.success = true
  snap promise: obj.action.call({})

  hookUp obj, 
    actions: "action"
    names:
      hookIn: "reg"
  obj.action.reg (o) => o.success = true
  snap promise: obj.action({})


  # should work with prefix
  hookUp obj,
    actions: 
      before: "action"
  obj.before.action.hookIn (o) => o.success = true
  snap promise: obj.before.action({})


  # should work with catch
  hookUp obj,
    actions: "action"
    catch: => return "success"
  obj.action.hookIn => throw new Error()
  snap promise: obj.action()