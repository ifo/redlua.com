+++
date = "2015-01-19T18:54:36-05:00"
draft = false
tags = ["haskell", "url shortener", "scotty", "lucid", "guide"]
title = "Url shortening in Haskell with Scotty and Lucid"

+++

This article is for beginners (because the author is one).
You should be familiar with basic Haskell syntax, though.
If you aren't, check out [Learn You a Haskell for Great Good!](http://learnyouahaskell.com/)

I want to play around with Haskell web frameworks, so let's make some Url shorteners!
I'll start with [Scotty](https://github.com/scotty-web/scotty),
using HTML templating provided by [Lucid](https://github.com/chrisdone/lucid).

## First, A Thank You

This post is heavily inspired by adit.io's excellent post [Making A Website With Haskell](http://adit.io/posts/2013-04-15-making-a-website-with-haskell.html), which helped me start doing pretty much anything in Haskell.

Also quite helpful was a Haskell [How I Start](http://howistart.org/posts/haskell/1) with Chris Allen, which greatly helped me with understanding Cabal and sandboxes.

It also uses information from [Scotty's Url Shortener example](https://github.com/scotty-web/scotty/blob/9cfadcd72dda1f23fa445072482488a14546155c/examples/urlshortener.hs).

## Set Up The Project

First, make a directory for it, `mkdir url-shortener`.
Change directory into it, `cd url-shortener`.
Then, initialize the cabal sandbox `cabal sandbox init`.
Finally, initialize the cabal project `cabal init`. Note, `cabal init` will ask you a lengthy series of questions. If you don't care, you can just hit enter through them all. If you want to answer some of them correctly, please note, the project Category is Web (option 18) and it's an Executable (option 2). All other options are the default (just hit enter).

Now let's look at the cabal file we've made. It's called `url-shortener.cabal`, or whatever you named your project, .cabal.
The only thing in here we will eventually care about is under `executable url-shortener`, and is called `build-depends`.
build-depends is where you list all the packages your project requires.
We'll be filling it in as we go along, but remember that it's important.

Quick Recap: we ran
```
mkdir url-shortener
cd url-shortener
cabal sandbox init
cabal init
```
and selected mostly default options, except Category = Web, and Package Build = Executable.

## Our First Site

Now let's start writing some code!
Open up Main.hs, and make it look like this:
```
{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty

main :: IO ()
main = scotty 3000 $ do
  get "/" $
    html "Hello World!"
```
And that's everything you need for a basic server that returns "Hello World!".
Now let's run it by typing `cabal build`, which will build our project ....
Except it failed, right?
It complained about not being able to find `Web.Scotty`?
Luckily for us, it then suggests that we're probably looking for the `scotty` module.
Let's go back to our `url-shortener.cabal` file and add it.
Add a comma at the end of the last module on the 'build-depends' line (should be called `base >=4.7 && <4.8` or something).
On the next line, write `scotty`.
Now go back and `cabal build` the project.
It might take a while, but it shouldn't complain about anything this time.

Once that finishes, to actually run the project, type `cabal run`.
Now you can go to `localhost:3000` in your web browser, and see your project say "Hello World!".

Now that that's all done, let's talk about what the code actually does.
```
{-# LANGUAGE OverloadedStrings #-}
```
This line is called a "pragma" in Haskell, and I don't really know what it does either.
What I can tell you is that in Haskell, Strings and Text are different (Text is more efficient).
Because Scotty uses Text instead of Strings, we add OverloadedStrings to make sure all our Strings are actually Text.
Anyway, on to stuff I actually understand.
```
import Web.Scotty
```
This is an import statement.
It tells your current file that you're going to use everything available in the Web.Scotty module.
If you want to see everything that that involves, check out the [Scotty module on GitHub](https://github.com/scotty-web/scotty/blob/58d0709dc472f601280481f44b5f29a53f6cab5f/Web/Scotty.hs#L8-L33).
With it, we now have access to the `scotty`, `get` and `html` functions, which you see later in the file.
```
main :: IO ()
main = scotty 3000 $ do

  get "/" $
    html "Hello World!"
```
The `main` function is run when we run our project.
It has the type of IO (it's going to output something, probably)
In this case, it runs scotty on port 3000, then allows us to write a series of `get` functions (or post, put, delete, etc), which handle our routes.

When we `get "/"`, we're handling the base url route "/".
In order to give the user something back, we need to use another Scotty function that determines the type of the response.
In this case, we're returning an html page. We could also return json, text, a file, a stream, or just raw.

Text actually would have been more appropriate, but we're going to use html eventually.
The html function in this case just takes our text and lets Scotty return it for the route it's in.

## Make A Form

Because our url shortener is going to need to take form input, let's use Lucid to make ourself a form.
Continuing with our previous file, replace the line `html "Hello World!"` with
```
html . renderText $
  html_ $
    body_ $ do
      h1_ "Title"
      p_ "Hello Lucid World!"
      with form_ [method_ "post", action_ "/"] $ do
        input_ [type_ "text", name_ "url"]
        with button_ [type_ "submit"] "Shorten"
```
and lets talk about it.

So all of those functions that end with \_, they're from Lucid.
They probably mean what you think they mean.
`html_` gives us an \<html\> tag to put things in.
Then we have our body.
We use the `do` to put multiple html tags within a single tag.
In this case, an \<h1\> tag containing our page title, a \<p\> tag, and finally our \<form\>.

And the `html . renderText`?
renderText is from Lucid, and it converts all of the `tag_` functions into text, which Scotty then sends with `html`, just like it was before when we had `"Hello World!"` in there.

#### What's with `with`?

So you see that `with`? It's how Lucid does html attributes.
The list after form is turned into its method and action atttributes.
Anything after that just gets put in the tag as normal.
We're putting an input and a button inside the form, and the button will have the type="submit" attribute.

Notice that our `input_` doesn't have the `with` function.
That's because inputs never contain values, but pretty much always need attributes.
If we look at the function in the Lucid library, it actually contains `with` in its [definition](https://github.com/chrisdone/lucid/blob/e6d0b123ead470fc6420a190eba74e30750708fe/src/Lucid/Html5.hs#L224-L226).

Now that that's out of the way, `cabal install && cabal run` again.

Oh, what's this, a ton of errors?
This time we need the Lucid library.
That's easy enough.
Just add `import Lucid` right below `import Web.Scotty`, then re-run the above.
Note, you only need to `cabal run` when you haven't added a new library to your cabal file.
Otherwise, you need to `cabal install` again.

## Getting Form Input

Minor problem, we're not handling our form post.
In fact, if you submitted something to the form above, you were met with a pretty nasty 404, with exclamation points and everything!

Let's fix this.

The `get` function handle's http GETs.
Scotty also has a `post` function, which handles http POSTs.
Below our get function, lets add a post, and just return html with "Welcome to post!"

Your file should currently look like this:
```
{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Lucid

main :: IO ()
main = scotty 3000 $ do

  get "/" $
    html . renderText $
      html_ $
        body_ $ do
          h1_ "Title"
          p_ "Hello Lucid World!"
          with form_ [method_ "post", action_ "/"] $ do
            input_ [type_ "text", name_ "url"]
            with button_ [type_ "submit"] "Shorten"

  post "/" $
    html "Welcome to post!"
```
That lovely `post` at the bottom will handle our form.
Go ahead and try it out!

#### Okay that's nice, but...

Okay okay, you actually want to handle the information posted.
Scotty lets us do this pretty easily.
We have to add a `do` to the end of our `post "/" $` line, and before the html, we bind our expected parameter.
It looks like this:
```
post "/" $ do
  url <- param "url"
```
Now that we have the url parameter (notice our form had `name_ "url"`), we should display it or something.
We do that with a lovely concat function from Data.Monoid, called `mconcat`.
Replace the html line with
```
html $ mconcat ["You just submitted: ", url]
```
Don't forget to import mconcat by adding `import Data.Monoid (mconcat)` somewhere below your `import Lucid`.
The `(mconcat)` section lets Haskell know that we only want the mconcat function, and no other parts of Data.Monoid.
It's probably not necessary, but it could help prevent potential name conflicts.

No need to `cabal install` this time, just run it to see your current masterpiece.

## Add A "Database"

We should actually eventually do url shortening, I guess.
To do that, we'll need somewhere to store our urls, and their shortened identifiers.
I'm going to borrow heavily _(read: steal)_ from the Scotty repo's [url shortener example](https://github.com/scotty-web/scotty/blob/58d0709dc472f601280481f44b5f29a53f6cab5f/examples/urlshortener.hs).

We'll need to import a bunch of new things to do this.
Add them somewhere near the top of the file.
```
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent.MVar (newMVar, readMVar, modifyMVar_)
import qualified Data.Map       as M
import qualified Data.Text.Lazy as LT
```
Now that we have those, let's create our database, somewhere before our first get, but still within the scotty function.
```
m <- liftIO $ newMVar (0::Int, M.empty :: M.Map Int LT.Text)
```
And we'll modify our post section to save the shortened url.
```
post "/" $ do
  url <- param "url"
  liftIO $ modifyMVar_ m $ \(i,db) -> return (i+1, M.insert i url db)
  html $ mconcat ["You just submitted: ", url]
```

#### Do you even liftIO? And other questions.

We just did a lot there.
Let's go through it.

Ignoring imports for now, we created our database.
```
urlMap <- liftIO $ newMVar (0::Int, M.empty :: M.Map Int LT.Text)
```
This essentially uses `urlMap` as our database variable.
It has the type (Int, Map Int Text), for example: (1, 0 "https://duckduckgo.com").
Creating this map will allow us to shorten the identifier "0" to point to duckduckgo.com.
The Int at the beginning will give us a new value to shorten the next url to.
We increment the first Int every time we insert a new url in our lambda function:
```
liftIO $ modifyMVar_ urlMap $ \(i,db) -> return (i+1, M.insert i url db)
```
So the next time we shorten a url, it's identifier will be "1", say for "https://google.com".

#### Okay, so what's `liftIO`?

To get an idea what `liftIO` does, try removing it from the `newMVar` line.
The compiler can't match the type, because it expects the `newMVar` to be a Scotty function like `get` and `post`, which take Lazy Text and turn it into IO.
What `liftIO` is doing is telling Scotty to not worry about these lines.
We want to use them, but they're not IO.
As to why it's called "lift", I have no idea :\\

#### And the imports?

Control.Monad.IO.Class and Control.Concurrent.MVar get us our `liftIO` and `mVar` functions, respectively.
The Data.Map gives us the structure for our database (mapping a shortened url to the url itself).
And the Lazy Text is what is bound by Scotty's param in: `url <- param "url"`.
We need to include it so we can use it in our map.

If you `cabal run` this new code, you'll notice it's asking for a bunch of new packages.
"transformers", "containers", and "text".
Adding them to the list in `build-depends` in our cabal file solves that problem.

## Adding The Redirect

Now we can make a route to redirect our shortened urls:
```
get "/:hash" $ do
  hash <- param "hash"
  (_,db) <- liftIO $ readMVar urlMap
  case M.lookup hash db of
    Nothing -> raise $ mconcat ["Url hash ", LT.pack $ show hash, " not found in database!"]
    Just url -> redirect url
```
This needs to be the last route in scotty, as the `"/:hash"` will match anything after "/", so you can't have any more routes after it.
(This is not technically accurate, as in this case `"/:hash"` will only match Integers, but it is practially true, and will eventually be the case when we're done. So just put it at the bottom and leave it there.)

We grab the hash the same way we grabbed the url before, with `param`.
Then we need to get our database, so we can see if a url matches.
Because our `urlMap` includes an integer for counting sake, we can ignore it and just grab the Map section.
After that, we look up the "hash" in our database.
If we don't find it, we give an error saying we didn't.
If we do find it, we redirect to it.

__Please note, redirect requires the starting "http(s)://", otherwise it'll redirect to some other part of our own page.
So please add that in the urls you are shortening.__

## Display All Currently Shortened Urls

You'll probably want to see all the urls you have shortened.
To show them all, we'll again steal from the Scotty url shortener example.
Add this route below the rest, but above `"/:hash"`.
```
get "/list" $ do
  (_,db) <- liftIO $ readMVar urlMap
  json $ M.toList db
```
Now if you shorten some urls and go to `localhost:3000/list`, you'll see the number that corresponds to each shortened url.

Since we have this new url list, lets change our post page to redirect to it, so we can see the new urls as we shorten them.
Remove the last line of the `post` route, and replace it with:
```
redirect "/list"
```

Note, if you shut down your application, all the shortened urls are gone.
That's because we're faking our database, instead of making an actual one (one of these days it'll happen, I'm sure).

## Putting It All Together

If you've been following along, your code might not look like the following.
I'm not that good of an author.
Yet ;).
But regardless you can copy and paste this and it'll likely work:

Main.hs:
```
{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Lucid

import Data.Monoid (mconcat)
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent.MVar (newMVar, readMVar, modifyMVar_)
import qualified Data.Map       as M
import qualified Data.Text.Lazy as LT

main :: IO ()
main = scotty 3000 $ do

  urlMap <- liftIO $ newMVar (0::Int, M.empty :: M.Map Int LT.Text)

  get "/" $
    html . renderText $
      html_ $
        body_ $ do
          h1_ "Title"
          p_ "Hello Lucid World!"
          with form_ [method_ "post", action_ "/"] $ do
            input_ [type_ "text", name_ "url"]
            with button_ [type_ "submit"] "Shorten"

  post "/" $ do
    url <- param "url"
    liftIO $ modifyMVar_ urlMap $ \(i,db) -> return (i+1, M.insert i url db)
    redirect "/list"

  get "/list" $ do
    (_,db) <- liftIO $ readMVar urlMap
    json $ M.toList db

  get "/:hash" $ do
    hash <- param "hash"
    (_,db) <- liftIO $ readMVar urlMap
    case M.lookup hash db of
      Nothing -> raise $ mconcat ["Url hash ", LT.pack $ show hash, " not found in database!"]
      Just url -> redirect url
```

url-shortener.cabal:
```
-- Initial url-shortener.cabal generated by cabal init.  For further 
-- documentation, see http://haskell.org/cabal/users-guide/

name:                url-shortener
version:             0.1.0.0
-- synopsis:            
-- description:         
license:             ISC
license-file:        LICENSE
author:              Your Name
maintainer:          your-email@example.com
-- copyright:           
category:            Web
build-type:          Simple
-- extra-source-files:  
cabal-version:       >=1.10

executable url-shortener
  main-is:             Main.hs
  -- other-modules:       
  -- other-extensions:    
  build-depends:       base >=4.7 && <4.8,
                       scotty,
                       lucid,
                       transformers,
                       containers,
                       text
  -- hs-source-dirs:      
  default-language:    Haskell2010
```
The most important part of the cabal file is the `build-depends` line.

# Let's Make Things Even Better

So our url shortener has some problems.

1. Our "short urls" are just integers
2. We don't have real persistence
3. Our links page doesn't actually include html links (\<a\> tags)
4. We have to type in the url including the "http://", instead of just "duckduckgo.com"
5. We don't handle shortened url conflicts

I'm going to fix the first point, but not the others.
I'll save them for another time.

## Make Some Random Strings

Short urls are better as random strings.
Let's make some using System.Random.
Up at the top, `import System.Random (randomRs, newStdGen)`.
Don't forget to add `random` to the build-depends list.
Though the compiler will let you know about that if you `cabal run` without it.

`randomRs` is a cool function that creates an infinite list of random _things_ bounded by whatever we choose.
All it needs is a range of _things_, such as "a" to "z", and a random generator like `newStdGen` to kick it off.
Because Haskell is perfectly fine with infinite lists, we'll just take the number of characters we want to randomly generate, and use that to shorten the url.

This is how we use it inside our scotty function:
```
gen <- liftIO newStdGen
let shortenedUrl = LT.pack $ take 7 $ randomRs ('a', 'z') gen
```
Again, we're lifting the `newStdGen` because its not actually IO.
We're also creating a `shortenedUrl` which is the first 7 random lowercase characters generated.
We choose 7 because it's probably long enough.
Who knows.

Now we can save that string into our database, but that means we need to modify the database itself.
It no longer needs the place keeping Int, and it is now a map from Lazy Text to Lazy Text.
```
urlMap <- liftIO $ newMVar (M.empty :: M.Map LT.Text LT.Text)
```
Any time we access it, we also no longer need to separate it from the Int that no longer exists.
Replace both instances of the `readMVar` lines with:
```
db <- liftIO $ readMVar urlMap
```
Which actually looks cleaner.
Bonus!

`cabal run` it, and shorten some more urls!
The shortened urls should now look closer to what you'd see on actual url shortening sites.

__Note, there was a caveat above, that "/:hash" would only match Integers.
That is no longer true, because the "hash" is now a random string.__

## Even Better Random Strings

Now all of our random strings are just lower case letters.
No numbers.
No upper case letters.
No other valid url characters, like - and \_.
We can do better.

Instead of using `randomRs` to generate a list of characters, we'll use it to generate a list of numbers.
Then, using those numbers, we'll take an alphabet that we'll specify, and look up the charcter in that list.
This will allow us to get any of the following characters in our shortened url:
`-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`

First, lets make our alphabet.
You could just copy the above string.
Lets be lazy instead, and build it with Haskell's list generation syntax:
```
alphabet :: String
alphabet = '-' : '_' : ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9']
```
Put this and the next functions outside of the `main` function.

We also need a function to convert our Int to the desired Char.
```
numToChar :: Int -> Char
numToChar x = alphabet !! x
```
This just grabs whatever character is at the specified index of `alphabet`.

Now we just replace our previous `shortenedUrl` function with one that will use our new `alphabet` and `numToChar`.
```
gen <- liftIO newStdGen
let shortenedUrl = LT.pack $ map numToChar $ take 7 $ randomRs (0, length alphabet - 1) gen
```
Wow, does that look bad.
Not to mention it's longer than 80 characters.
We should probably pull it into its own function, and clean it up a bit.
Feel free to shorten some urls first, to make sure it actually works.

Anyway, lets just give ourselves a function that'll take a number of characters to generate, as well as a generator, and return the random String.
We can also clean up our functions by putting `alphabet` and `numToChar` into our new function.
This prevents us from making too many named functions on the global namespace.
```
makeRandomString :: RandomGen g => Int -> g -> String
makeRandomString x gen =
  map numToChar $
  take x $
  randomRs (0, length alphabet - 1) gen
  where
    alphabet :: String
    alphabet = '-' : '_' : ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9']

    numToChar :: Int -> Char
    numToChar x = alphabet !! x
```

What's all this do? I'm glad you asked.
`makeRandomString` takes two arguments: a number of characters to generate, and a random generator.
In our case, this is still `newStdGen`.
The `where` clause allows us to name functions that exist only within `makeRandomString`.
That way, no other functions know about them, because no other ones need to.

Now we can change our shortenedUrl to something a little more concise:
```
gen <- liftIO newStdGen
let shortenedUrl = LT.pack $ makeRandomString 7 gen
```

In order to compile with this new function `makeRandomString` we'll need to add `RandomGen` to our System.Random import.
```
import System.Random (randomRs, newStdGen, RandomGen)
```

## Done And Done

Well that took a while.
Hopefully you learned something, or at least weren't bored by this.
In a future post, we'll go over points 2, 3, 4 and 5 listed above:

- Making our "links" page actually have links
- Adding real persistence
- Allowing shorter urls without the leading "http://"
- Handle potential shortened url conflicts

You can check out the "final" code of this tutorial [here](https://github.com/ifo/scotty-lucid-url-shortener/tree/c7a273bdd55b9277e9ad2a29cba827025c6342ab), and see the most recent version of the url shortener [here](https://github.com/ifo/scotty-lucid-url-shortener).
