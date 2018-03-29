+++
title = "Rename a field in RethinkDB"
url = "post/rename-a-field-in-rethinkdb/"
date = "2016-03-04T14:07:54-05:00"
tags = ["tips", "rethinkdb"]
+++

So you have a document in RethinkDB with a field name that is wrong.
Maybe you're like me and you called something `time_stamp`, because you know
that both time and stamp are individual things, but forgot that when combined,
they're just one thing: `timestamp`.
Either way, you need to rename that field.

To do that, you use RethinkDB's `replace`, `without`, and `merge` commands,
exactly like what someone said
[here](https://groups.google.com/forum/#!topic/rethinkdb/5L6PSlPGKzc).

```js
r.db('test').table('test').replace(function(elem) {
  return elem.without('time_stamp').merge({'timestamp': elem('time_stamp')});
});
```

Boom, field renamed.
Though if you're also using it as an index, like I am, remember to do this too:

```js
r.db('test').table('test').indexRename('time_stamp', 'timestamp');
```

#### A quick note on terms

You also may, like myself, have considered a field in a document to be a column
like what you'd call it in SQL.
Or maybe a key, like you'd call it in a hash table (or dictionary or object or
map or whatever).
Though people will probably still know what you're talking about, in RethinkDB,
they're apparently called fields.
So now we both know :)
