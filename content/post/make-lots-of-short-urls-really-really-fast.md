+++
date = "2016-02-29T16:08:17-05:00"
draft = false
tags = ["ten by six", "url shortener", "golang"]
title = "Make lots of short urls really really fast"

+++

#### This is another [ten by six](/tags/ten-by-six) update!

I'd like to introduce to you [sanic](https://github.com/ifo/sanic/), a unique id
/ short url generator based off of [Twitter's 2010 Snowflake code]
(https://github.com/twitter/snowflake/tree/snowflake-2010).

[Url Shorteners](/post/url-shortening-in-haskell-with-scotty-and-lucid/) have
[long](https://github.com/ifo/haskell-spock-lucid-url-shortener) been an
[interest](https://github.com/ifo/clojurl) of [mine]
(https://github.com/ifo/probablyvalidurl.com), but my ID generation method up to
this point has been making random strings and checking that they don't already
exist.

And I must admit, making random strings is really convenient!
The code is relatively [small and simple]
(https://github.com/ifo/probablyvalidurl.com/blob/fe7702119de7f1d133b8fd64474758f190ff0622/strings.go).
But random strings have some issues at scale.

## What's wrong with random strings?

When you need to generate lots of unique IDs, you have to ensure that they never
conflict.
This is fairly avoidable with good hashing algorithms and things like UUIDs.
But those are both veeeeeeeery long, which means you can get away with leaving
them to their randomness.

But when it comes to **short** random strings, it means you must keep a
canonical set of all strings that have ever been used, then check each time you
make one that you haven't already made that same one before.
Otherwise, you can't guarantee their uniqueness.
And that can only really be done by centralizing your
string-uniqueness-monitor-thing.
Which means you now have a single point of failure, and a very overworked
component (at scale, anyway).

## So what does sanic do?

sanic gets around these issues by being deterministic.
It creates a timestamp, and then increments a limited counter for every ID it
generates during that timestamp.
If it ever runs out of space in the ID counter, it simply waits until the next
timestamp comes around (which is between 1 millisecond to 1 second, depending on
what you choose).

It also uses a worker ID (which must be unique), so that multiple servers or
processes can all be generating IDs in parallel.

With these pieces of information, it simply appends them all together, so there
can never be the same combination of timestamp + counter + workerID (until a
number of years have elapsed, and the timestamp overflows, anyway :)

## So how do I use it?

Right now, you probably shouldn't ;)
While sanic is fairly complete for its needs, it lacks tests and documentation.
Also, you have to be careful when using it, as it has no built in concurrency
safety.
If you use it with the Golang http standard library, you're gonna have a bad
time unless you handle the concurrency issues yourself.

Fear not, though!
I'll be updating sanic with tests, and likely have a followup blog post where I
give an example of how to use it.
