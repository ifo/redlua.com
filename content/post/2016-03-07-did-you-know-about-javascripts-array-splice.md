+++
title = "Did you know about JavaScript's Array.splice()?"
url = "post/did-you-know-about-javascripts-array-splice/"
date = "2016-03-07T14:11:51-05:00"
tags = ["tips", "javascript"]
+++

'Cause until yesterday, I didn't.

If you want to know the most about it, go
[here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice).
But if you just want a quick overview, you're in the right place.

## The array operation I was missing

So I already knew about `push()`, `pop()`, `shift()` and `unshift()`, the lovely
methods that let you manipulate the ends of an array (again, check
[here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
if you want all the information).
But I'd never thought about how to add or delete an element in the middle of an
array.
Turns out, that's `splice()`.

## How does it work?

`splice()` takes at least 2 arguments, and up to ∞ arguments.
The first argument is the index of the array that you want to start at.
The second argument is the number of things you want to delete, starting with
that index (0 is a totally valid number of things to delete).
The remaining ∞ optional arguments are any elements you want to insert into the
array, again, at that index.

`splice()` returns an array of the elements deleted (which is `[]` if no
elements were deleted).

**Be Careful!** Because `splice()` works like the above array operations, it
means that using it modifies the array everywhere, not just inside the function
you're using it in.
So be careful.

## A quick example

So let's say you have an array of cool things:
```js
var coolThings = ['cat', 'banana', 'dog'];
```
If you want to get the banana, and leave the cool things to just be animals, you
can `splice()` it!
```js
var edibleThings = coolThings.splice(1, 1);
console.log(coolThings);   // [ 'cat', 'dog' ]
console.log(edibleThings); // [ 'banana' ]
```
Neat!

One more example real quick:
```js
var awesomeNumberSymbols = ['∞', 'i', 'cow', 'e'];
// whoops I meant 'π' not 'cow' (a common mistake for me)
var sadCow = awesomeNumberSymbols.splice(2, 1, 'π');
console.log(awesomeNumberSymbols); // [ '∞', 'i', 'π', 'e' ]
console.log(sadCow);               // [ 'cow' ]
```

Now that you know, you can go and `splice()` some things!

... Just be careful with it, okay?
