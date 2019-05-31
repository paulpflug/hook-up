{test} = require "snapy"
hookUp = require "../src/hook-up.coffee"
obj = {
  test: 3
}
test (snap) =>
  # test basic actions and args1 and args2
  hookUp obj, ["action1","action2"]
  obj.action1.hookIn (o, _obj) -> 
    o.test += @test + _obj.test
  # should show 8
  snap promise: obj.action1({test:2})
  adder = (o) => o.test++
  obj.action2.hookIn adder
  obj.action2.hookIn adder
  obj.action2.hookIn adder
  # should show 3
  snap promise: obj.action2(test:0)

test (snap) =>
  # test renaming
  hookUp obj,
    actions: "action"
    names:
      hookIn: ""
      call:"call"
  obj.action (o) => o.success = true
  # should show success
  snap promise: obj.action.call({})
  hookUp obj, 
    actions: "action"
    names:
      hookIn: "reg"
  obj.action.reg (o) => o.success = true
  # should show success
  snap promise: obj.action({})

test (snap) =>
  # test prefix
  hookUp obj,
    actions: 
      before: "action"
  obj.before.action.hookIn (o) => o.success = true
  # should show success
  snap promise: obj.before.action({})

test (snap) =>
  # test catch
  hookUp obj,
    actions: "action"
    catch: (e, obj ) => 
      # should have Error
      snap obj: e
      # should have obj
      snap obj: obj?
      return "success"
  obj.action.hookIn => throw new Error("Error")
  # should show success
  snap promise: obj.action()

test (snap) =>
  # test additional args
  hookUp obj,
    actions: "action"
    args: "success"
  obj.action.hookIn (arg1,arg2,arg3) =>
    # should show success
    snap obj:arg3
  obj.action()
  hookUp obj,
    actions: "action"
    args: ["success1","success2"]
  obj.action.hookIn (arg1,arg2,arg3,arg4) =>
    # should show success, success
    snap obj:[arg3,arg4]
  obj.action()

test (snap) =>
  # test state
  hookUp obj,
    actions: "action"
    state: action: "acting"
  obj.action.hookIn => 
    snap obj: obj.state
    #first false
    obj.currently.acting.then => snap obj: obj.currently
    return null
  #second false
  obj.action().then => snap obj: obj.currently

  # test state naming - should have result
  hookUp obj,
    actions: "action"
    state: action: "acting"
    names:
      state: "status"
  obj.action().then => snap obj: obj.status