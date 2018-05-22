# hook-up

**Speed, functionality, simplicity - choose two.**

This fundamental tradeoff in programming is as true as always.
We are just better at hiding complexity - regular severe security flaws are a reminder of what we already hid away.

The only way we can improve this tradeoff is *clever program design*.

Over the last few years of programming I produced two very helpful guidelines
- aim for declarative programming
- separate by functionality

## Aim for declarative programming

Make your programs work with configuration files - the most common type of declarative programming.
They can be easily read, merged, diffed and shared.

Common settings of different projects can be easily extracted and maintained in one place.

I created [read-conf](https://github.com/paulpflug/read-conf) as a powerful configuration reader with watching and plugin functionality.

## Separation by functionality
Separation by functionality greatly improves extendability and understandability - thus maintainability.

You probably experienced the need for a major refactoring or even a complete rewrite at least once. And you will remember the large impact this had on your project - This happens when functionality isn't separated properly.

I'm using two design pattern for different types of programms:
- user interface: mixins (used in [cerijs](https://github.com/cerijs/ceri))

Each functionality is encapsulated in one mixin. 
A user interface component and each mixin can depend on other mixins.
You need one main merging algorithm to resolve the dependency tree and merge all functionality into your ui-component.

- processing programs: plugins and actions (used in [leajs](https://github.com/leajs/leajs) or [snapy](https://github.com/snapy/snapy))

Think of an action as an 2d array of callbacks where a state can progress through.
Each callback only interacts with the current (action and/or program) state.

```
# cb2 and cb3 will be called simultaneously but only after cb1 is finished
# there is empty space where plugins could hook in more cbs
{actionState, programState} -> [cb1, , , , [cb2, cb3], , ,] -> {actionState}
```

A plugin can hook in in those actions on any position.

This package is an action builder working in node and in browser (in combination with e.g. webpack)


### Install
```sh
npm install --save hook-up
```

### Usage
```js
hookUp = require("hook-up")

program = {
  config: {}
}

// hookUp(obj:Object, options:Object)
hookUp(program,{
  actions: {
    {"": "run"},
    {"cache": ["get", "set"]}
  },
  catch: {
    "cache.get": (e) => { console.error(e) } 
  },
  args: [someArg]
})

// hookIn([position:Number], cb:Function)
// position defaults to program.position.during
// (see below)
program.run.hookIn((state,{config},someArg) => {
  // config equals program.config
  // someArg is passed from above
  // it is recommend to test the state if you depend on it
  // as you have no idea what the previous cbs did
  if (// is in correct state) {
    // doSomething with state
  } 
  // you don't need to return anything, each cb will be
  // called with the current action and program state
  // if you return a promise or the cb is async
  // the next cb will only get called afterwards
})
result = await program.run({})

// remove all cbs
program.run.reset()

// program.position
// with a default spread of 8
// contains the predefined positions:
// {init: 0,before: 8, during: 16, after: 24, end: 32}
program.run.hookIn(program.position.init, (state) => {
  // init state somehow
})
```

For the separation by functionality design pattern each functionality needs to be a separate plugin (not necessarily a separate package). These plugins need access to the actions of your program.
#### Options
Name | type | default | description
---:| --- | ---| ---
actions | String or Array or Object | - | name of the actions - maximum 1 depth
catch | Object | - | lookup object to apply default catch functions to actions
spread | Number | 8 | distance between the predefined positions
position | Object | - | lookup object to use as predefined positions
Promise | Object | native Promise | Promise lib to use
args | Object or Array of Objects | - | additonal args passed on each action call
names | Object | - | see below

you can change the default names:
```js
// available: "hookIn", "reset", "position", "call"
hookUp(program = {},{
  actions: "run",
  names:{
    hookIn: "", // only one of hookIn or call can be empty
    reset: "clear",
    position: "pos",
    call: "call"
  }
})

program.run(program.pos.init,(state)=>{
  // do something
})
result = await program.run.call({})
program.run.clear()
```

## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
