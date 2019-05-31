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

setupAction = (actionName, obj, {catch:catcher,names,default:def,Promise,args, state, _state, _last}) ->

  catcher = catcher[actionName] if catcher? and not isFunction(catcher)

  if args?
    unless isArray(args)
      args = [obj, args]
    else
      args.unshift(obj)
  else
    args = [obj]

  stateName = state?[actionName]

  call = (o) -> 
    o ?= {}
    _args = args.slice()
    _args.unshift(o)
    done = (action._chain.reduce ((lastPromise, hooks) ->
      if hooks.length == 1
        return lastPromise.then -> hooks[0].apply(obj, _args)
      else
        return lastPromise.then -> Promise.all hooks.map (hook) -> hook.apply(obj, _args)
      ), Promise.resolve())
      .then ->
        _state[stateName] = false if stateName and _state[stateName] == done
        return o
      .catch (e) ->
        _state[stateName] = false if stateName and _state[stateName] == done
        if catcher?
          catcher.apply(obj, (tmp = _args.slice(1)).unshift(e) && tmp)
        else
          throw e
    _state[stateName] = done if stateName
    return done

  hookIn = (index, cb) ->
    if isFunction(index)
      cb = index
      index = def
    else unless isFunction(cb)
      {cb, index} = index
      index ?= def
    unless cb? and index?
      hookInName = "."+names.hookIn or " hooking-in"
      throw new Error "#{actionName}#{hookInName} needs a 'cb' and a 'index'"
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

  action[names.reset] = action._reset = -> action._chain = []
  action._reset()

  return action


setup = module.exports = (obj, options) ->
  if options?
    if isString(options) or isArray(options)
      options = actions: options
    options.Promise ?= Promise
    names = options.names ?= options.name || {}
    names.hookIn ?= "hookIn"
    names.call ?= ""
    names.reset ?= "reset"
    names.position ?= "position"
    names.state ?= "currently"
    if options.position?
      position = options.position
      last = 0
      for k,v of position
        last = v if v > last
      options._last = last
    else
      spread = options.spread || 8
      position = {}
      for name,i in (options.positions || positions)
        position[name] = i*spread
      options._last = i*spread
    if (def = options.default)?
      if isString(def)
        options.default = position[def]
      else
        options.default = def
    else
      options.default = position[defaultPosition]

    obj[names.position] = position

    if options.state?
      options._state = obj[names.state] = {}

    _actions = []
    obj[names.reset+"AllActions"] = =>
      for _action in _actions
        _action._reset()

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