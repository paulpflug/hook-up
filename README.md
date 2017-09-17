# hook-up

2d hooks - better than events or simple hooks

### Install
```sh
npm install --save hook-up
```

### Usage
```js
hookUp = require("hook-up")
// hookUp(obj:Object, prefix:String | Array of Strings)
// prefix is optional and defaults to ["before","after"]
someObj = {}
hookUp(someObj, "before")
// adds a function:
// registerHooks(names:String | Array of Strings)
someObj.registerHooks("start")
// adds functions 
// to add a hook
// [prefix].[name].call({prio: (optional) Number, cb: Function})
// to call all hooks
// [prefix].[name](obj)
// to delete all hooks
// [prefix].[name].clear()
someArg = {}
someHook = async (arg) =>
  // this == someObj
  // arg == someArg
  // do something async
someObj.before.start.call(someHook)
someObj.before.start.call({prio: 2, cb: someHook}) // bigger prio gets called first
// hooks with the same prio get called simultaneously
await someObj.before.start(someArg)
```


## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
