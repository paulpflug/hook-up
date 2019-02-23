{resolve, basename, extname} = require "path"
{readdirSync} = require "fs"
VirtualModulePlugin = require('virtual-module-webpack-plugin')

module.exports = ({base, actions, plugins}) => (compiler) =>
  # whitelist injected bootstrap
  ext = compiler.options.externals ?= []
  ext = compiler.options.externals = [ext] unless Array.isArray(ext)
  compiler.options.externals = ext.map (obj) =>
    if typeof obj == "function"
      fn = obj
      obj = (ctx, req, cb) =>
        return fn(ctx, req, cb) if req != "hook-up/bootstrap"
        cb()
    return obj

  resolve_base = resolve.bind(null,resolve(compiler.options.context,base))
  actionFiles = readdirSync(resolve_base(actions)).map (file) => basename(file,extname(file))+":require('"+resolve_base(actions,file)+"')"
  plugins.push(actions) unless ~plugins.indexOf(actions)
  pluginFiles = plugins.map (folder) => 
      readdirSync(resolve_base(folder))
      .map((file) => resolve_base(folder, file))
    .reduce (acc, curr) => Array::push.apply(acc,curr); return acc
    .map (file) => "require('"+file+"')"
  result = """
    module.exports = function(obj, opts) {
      var hookUp, actions, plugins, s, name
      hookUp = require("hook-up")
      if (opts == null) {opts = {}}
      if (opts.actions == null) {opts.actions = []}
      if (opts.state == null) {opts.state = {}}
      if (opts.catch == null) {opts.catch = {}}
      actions = {#{actionFiles.join(",")}}
      for (name in actions) {
        opts.actions.push(name)
        if ((s = actions[name].state)!=null) {opts.state[name] = s}
        if ((s = actions[name].catch)!=null) {opts.catch[name] = s}
      }
      hookUp(obj, opts)
      plugins = [#{pluginFiles.join(',')}]
      workers = []
      load = (plugin) => {
        if (typeof plugin === "function"){
          workers.push(plugin(obj))
        } else {
          console.log("hook-up (warn): plugin is not of type function")
        }
      }
      plugins.forEach(load)
      if (obj.plugins != null) {obj.plugins.forEach(load)}
      return Promise.all(workers)
    }"""
  vmp = new VirtualModulePlugin
    path: resolve(compiler.options.context,"node_modules/hook-up/bootstrap.js")
    contents: result
  vmp.apply(compiler)
    
     
