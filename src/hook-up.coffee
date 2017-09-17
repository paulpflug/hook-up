isFunction = (fn) => typeof fn == "function"
arrayize = (obj) =>
  if Array.isArray(obj)
    return obj
  else if obj?
    return [obj]
  return []

getHook = (obj) =>
  arr = []
  exec = null
  hook = (o) => 
    exec = getExec() unless exec?
    await exec(o)
  hook.call = (o) =>
    if isFunction(o)
      o = hook: o, prio: 0
    unless o?.hook? and o.prio?
      throw new Error "a hook needs a 'hook' and a 'prio' property"
    arr.push o
    hook.exec = exec = null
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
    return hook.exec = exec = (o) =>
      for callHooks in reduced
        await callHooks(o)
  hook.clear = =>
    hook._hooks = arr = []
    hook.exec = exec = null
  hook._hooks = arr
  return hook

module.exports = (obj, prefix) =>
  prefix ?= ["before","after"]
  prefix = arrayize(prefix)
  for prop in prefix
    obj[prop] = {}
  obj.registerHooks = (names) =>
    names = arrayize(names)
    for prop in prefix
      tmp = obj[prop]
      for name in names
        tmp[name] = getHook(obj)