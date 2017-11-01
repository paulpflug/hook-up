# hook-up

Create your own hook api with 2-dimensional hooks - better than events or simple hooks.

### Install
```sh
npm install --save hook-up
```

### Usage
```js
hookUp = require("hook-up")
// hookUp(obj:Object, options:Object)
someObj = {}
hookUp(someObj)
// adds a function:
// registerHooks(names:String | Array of Strings)
someObj.registerHooks("start")
// adds functions 
// to add a hook
// [name].register({prio: (optional) Number, cb: Function})
// to call all hooks
// [name].execute(obj)
// to delete all hooks
// [name].clear()
someArg = {}
someHook = async (arg) =>
  // this == someObj
  // arg == someArg
  // do something async
someObj.start.register(someHook)
someObj.start.register({prio: 2, cb: someHook}) // bigger prio gets called first
// hooks with the same prio get called simultaneously
await someObj.start.execute(someArg)
```
#### Options
Name | type | default | description
---:| --- | ---| ---
prefix | Array or String | - | to add a namespace for all hooks
register | String | `register` | name of the register prop, can be empty
execute | String | `execute` | name of the execute prop, can be empty

Note, that only one of register or execute can be empty

### Example for custom API
```js
hookUp = require("hook-up")
someObj = {}
hookUp(someObj,{prefix:["before","after"], register: "call", execute:""})
someObj.registerHooks("start")
// will result in the following api for hooks:
someObj.before.start.call(someHook)
someObj.after.start.call(someOtherHook)
// to execute
await someObj.before.start(someArg)
```



## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
