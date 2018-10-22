+++
title = "A few thoughts on Interfaces and Abstract Classes"
date = 2018-10-07T21:08:02-04:00
tags = ["musings", "ironblogger"]
+++

As someone who has tended to avoid many aspects of Object Oriented Programming, I've only recently come across the concept of abstract classes.
Interfaces, however, I've known about for a while.
So in learning about them, I have found abstract classes interesting, but also not something I think I would want to use.

## But first, some definitions

For the sake of this short musing:

An interface is a list of functions (or methods) that an object (or class) has to define, if it wants to satisfy that interface.

An abstract class is a object that can have any number of functions, not all of which need to be defined.

Neither of the two can be instantiated on their own, but require another object to extend or implement them.
And whatever implements an interface has to specify every function.
But whatever extends an abstract class only has to specify every unimplemented function.

When I say "larger" or "smaller", I tend to mean in the amount of functionality something has.
Like, an object with many functions with be larger, and object with few functions would be smaller.
Also, I'm going to use function and method interchangeably, as well as object and class.
Sorry.

## So now some thoughts

I tend to think about things from the perspective of Golang, the language with which I am most familiar, and most enamored.
So I think of interfaces as specifying required behavior, but also being very lightweight.

By lightweight, I mean it's not a bad idea to have an interface be a single function, so long as that function is the behavior you need that interface to have.
But also, lightweight in the sense that it's fine to have interfaces that have some overlap.
Your one function interface might be an entire subset of another two function interface.
And that's fine, because Golang makes it easy to use interfaces in that way.

The opposite of that, having an interface that specifies a very large number of methods, seems like it's usually not a great idea.

All of this makes abstract classes somewhat confusing to me.
They appear to be interfaces, in that they also _seem_ to want to specificy behavior.
Except you can also specify the internals of some of the functions that you want, so that the extending class doesn't have to implement them itself.

But everything still gets implemented eventually anyway, so this seems like it's mostly a time saving measure more than anything else.
Or worse, it may encourage you to make larger classes, because making them larger might not add all that much extra work if you define a lot of the functions you want to require.
So you don't have to do as much work to create them.

**Potentially important side note**: I personally consider it a good thing when a language or framework makes it more difficult to do something it doesn't want you doing.
So if a language wants smaller classes, but still makes it easy to make larger ones, I don't think that is a good thing, even if it does give one more options.

Also, you _could_ get much of the same functionality by pairing an interface with a base class.
Your concrete class can extend the base class and implement the interface.
But if you did that, you wouldn't get the same direct language integration that abstract classes give you, and there are still a few other limitations.
Though I'm always a little wary when a language gives you two different ways to do things that appear to be quite similiar.

## An unsatisfying conclusion

So I'll say, after only giving this a little thought, I'm not entirely sure where I would use abstract classes.
They seem more beneficial for situations where your "interface" would be quite large, so you don't want to require the implementer to write every single function.
However, that seems like it would encourage people to write objects with a large number of functions, because you don't always have to implement all of them.
And based on my personal opinion, that seems like it is not ideal.
Also, though my experience with these has been _very_ limited, I haven't seen any small abstract classes.

Regardless, I still intend to ask folks about them and where they should be used, so I can learn more about the ways people decide to design things.
So if you see me and you have thoughts on the matter, I'd love to hear them!
