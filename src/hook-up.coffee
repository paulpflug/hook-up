isFunction = (fn) => typeof fn == "function"
arrayize = (obj) =>
  if Array.isArray(obj)
    return obj
  else if obj?
    return [obj]
  return []

getHook = (obj, options) =>
  arr = []
  exec = null
  execute = (o) => 
    exec ?= getExec()
    await exec(o)
  register = (o) =>
    if isFunction(o)
      o = hook: o, prio: 0
    unless o?.hook? and o.prio?
      throw new Error "a hook needs a 'hook' and a 'prio' property"
    arr.push o
    exec = null
  getExec = =>
    reduced = (arr.reduce ((acc, current) =>
        tmp = acc[current.prio] ?= [] 
        tmp.push current.hook.bind(obj)
        return acc
      ), []).map (hooks) =>
      if hooks.length == 1
        return hooks[0]
      else
        return (o) => Promise.all hooks.map (hook) => hook(o)
    return exec = (o) =>
      for callHooks in reduced
        await callHooks(o)
  if options.register == ""
    hook = register
    hook[options.execute] = execute
  else if options.execute == ""
    hook = execute
    hook[options.register] = register
  else
    hook = {}
    hook[options.execute] = execute
    hook[options.register] = register
  hook[options.clear] = =>
    hook._hooks = arr = []
    exec = null
  hook._hooks = arr
  return hook

module.exports = (obj, options) =>
  options ?= {}
  if options.prefix?
    prefix = arrayize(options.prefix)
  options.register ?= "register"
  options.execute ?= "execute"
  options.clear ?= "clear"

  obj.registerHooks = (names) =>
    names = arrayize(names)
    if prefix
      for prop in prefix
        obj[prop] = {}
      for prop in prefix
        tmp = obj[prop]
        for name in names
          tmp[name] = getHook(obj, options)
    else
      for name in names
        obj[name] = getHook(obj, options)