isFunction = (fn) -> typeof fn == "function"
isArray = Array.isArray.bind(Array)
arrayize = (obj) ->
  if isArray(obj)
    return obj
  else if obj?
    return [obj]
  return []
isString = (str) -> typeof str == "string" or str instanceof String

positions = ["init","before","during","after","end"]

defaultPosition = "during"

setupAction = (actionName, obj, {catch:catcher,names,default:def,Promise,args}) ->

  catcher = catcher[actionName] if catcher? and not isFunction(catcher)

  if args?
    unless isArray(args)
      args = [obj, args]
    else
      args.unshift(obj)
  else
    args = [obj]

  call = (o) -> 
    o ?= obj
    _args = args.slice()
    _args.unshift(o)
    promise = (action._chain.reduce ((lastPromise, hooks) ->
      if hooks.length == 1
        return lastPromise.then -> hooks[0].apply(obj, _args)
      else
        return lastPromise.then -> Promise.all hooks.map (hook) -> hook.apply(obj, _args)
      ), Promise.resolve()).then -> return o

    return promise.catch catcher if catcher?
    return promise

  hookIn = (index, cb) ->
    if isFunction(index)
      cb = index
      index = def
    else unless isFunction(cb)
      {cb, index} = index
      index ?= def
    unless cb? and index?
      hookInName = names.hookIn or "hooking-in"
      throw new Error "#{hookInName} needs a 'cb' and a 'index'"
    tmp = action._chain[index] ?= []
    tmp.push cb
    return -> tmp = tmp.splice i, 1 if ~(i = tmp.indexOf(cb))
      
  if names.hookIn == ""
    action = hookIn
    action[names.call] = call
  else if names.call == ""
    action = call
    action[names.hookIn] = hookIn
  else
    action = {}
    action[names.call] = call
    action[names.hookIn] = hookIn
  action._chain = []
  action[names.reset] = -> action._chain = []

  return action


module.exports = (obj, options) ->
  if options?
    if isString(options) or isArray(options)
      options = actions: options
    options.Promise ?= Promise
    names = options.names ?= {}
    names.hookIn ?= "hookIn"
    names.call ?= ""
    names.reset ?= "reset"
    names.position ?= "position"
    if options.position?
      position = options.position
    else
      spread = options.spread || 8
      position = {}
      for name,i in (options.positions || positions)
        position[name] = i*spread
    if (def = options.default)?
      if isString(def)
        options.default = position[def]
      else
        options.default = def
    else
      options.default = position[defaultPosition]

    obj[names.position] = position
    _actions = []
    obj[names.reset+"AllActions"] = =>
      for _action in _actions
        _action._chain = []
    actions = options.actions
    if isString(actions)
      actions = [actions]
    if isArray(actions)
      actions = {"": actions}
    
    for k,v of actions
      if k
        tmp = obj[k] = {}
      else
        tmp = obj
      for action in arrayize(v)
        actionName = if k then k+"."+action else action
        _actions.push tmp[action] = setupAction(actionName, obj, options)

  