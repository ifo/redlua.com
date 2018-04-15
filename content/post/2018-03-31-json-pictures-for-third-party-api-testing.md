+++
title = "json.pictures for third party api testing"
url = "post/json-pictures-for-third-party-api-testing/"
date = 2018-03-31T18:28:46-04:00
tags = ["25 5", "testing"]
+++

This is the first project in my [current 25:5 process](/post/starting-25-5),
which you can follow with the [25:5 tag](/tags/25-5/).

## json.pictures

So this project isn't live, and may never be.
You can get the code for it [here](https://github.com/ifo/json.pictures).

But it is complete as far as what I was looking to do.
That being - you can use this to test your code's usage of third party apis, by
copying an actual api call's response, POSTing it to a running instance of this
project, and then hitting the same url with a GET request to have that same json
returned back to you.

This works by essentially having a single map containing any relevant url paths.
When someone POSTs to a url, it will record whatever the POST body was, and put
it in the url map.
Then, when someone does a GET request, it will look up the url path in the map,
and if it finds that path, it'll return the POST body it received earlier.

There's no permanent persistence, or even a way to remove urls.
But you _could_ spin up an instance of it, post the records you want to receive
in your tests, and then run your tests.

## Why is this so basic?

It's an extremely manual process, and only supports GET requests, because it's
intentionally an MVP.

Features like supporting different request types or making it easier to setup
your json payload are out of scope to getting the simplest possible thing
working.

Sometimes the simple thing is all you need.
Many times it is not, and you _do_ need to add those features later.
But if you add all the features you _think_ you'll need up front, it'll take
longer to make.
That means you'll have less time using it than you could, and the pain points or
awesome features will take longer to find.
You'll also probably run into features you don't need but did spend time
developing.

New project development is generally a cycle:

1. Make or update something
2. Use it
3. Repeat

And the sooner you can get to using it from making it, the faster you can get to
fixing the starting problems and adding the things you truly need.

## So what'd you learn?

Mostly one thing that's important enough to say twice.
Thanks for asking!

I'd say the biggest thing I learned is how simple the mvp could be.
It's essentially one http handler that either reads from or writes to a map.
If I wanted to add a lot more, it'd probably be a fair bit more than that.
But to just do what it does, it was only 66 lines of Go.

Relatedly, I just think this was great practice on doing as little as is
necessary.
I've _definitely_ started projects that ended up getting stuck in the weeds on
small details before I'd even started working on the actual functionality.
I really think this'll help me get going on the core of a project
instead of getting caught setting up things I might theoretically need later.

## Next project: https.quine.space

The next project which is already complete is
[https.quine.space](https://https.quine.space).
My post on that is going to be more of a tutorial on handling https in Go and
less about the project's specifics.
