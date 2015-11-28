+++
date = "2015-07-27T18:54:36-05:00"
draft = false
title = "Functional programming terms in my own words"

+++

This article is a reference (mostly for myself) that gives simple explanations for functional programming terms.
It also shows relations between terms.

Much of the information here has been learned from the excellent book, [PureScript by Example](https://leanpub.com/purescript/read).

# Terms

### Type Class
A thing.

### Semigroup
A type class that supports concatenation.

The concatentation operatior is `<>`
```
class Semigroup a where
  (<>) :: a -> a -> a
```

#### Examples
* Arrays: `[1,2] <> [3,4] = [1,2,3,4]`
* Strings: `"hi " <> "everyone" = "hi everyone"`

### Monoid
A type class that has an empty value.

```
class (Semigroup m) <= Monoid m where
  mempty :: m
```

A Monoid is also a:

* Semigroup

#### Examples
* Arrays: `[]`  in: `[1,2] <> [] = [1,2]`
* Strings: `""` in: `"" <> "hey"= "hey"`


### Foldable
A type class. Still working on the mental model for this one.

Here are the laws:
```
class Foldable f where
  foldr :: forall a b. (a -> b -> b) -> b -> f a -> b
  foldl :: forall a b. (b -> a -> b) -> b -> f a -> b
  foldMap :: forall a m. (Monoid m) => (a -> m) -> f a -> m
```

### Functor
A type class that uses the lifting operator (think map).

```
class Functor f where
  (<$>) :: forall a b. (a -> b) -> f a -> f b
```

It also follows the following laws:

* Identity law:     `id <$> x = x`
* Composition law:  `g <$> (f <$> x) = (g <<< f) <$> x`

### Applicative
Defines pure and <*>

An applicative is a:

* Functor
