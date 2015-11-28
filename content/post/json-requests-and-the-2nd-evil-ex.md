+++
date = "2015-07-20T18:54:36-05:00"
draft = false
title = "JSON requests and the 2nd Evil Ex"

+++

### How do JSON requests work?

Whenever you make a JSON request on the internet, you are coming dangerously close to reenacting Scott's fight with Lucas Lee in Scott Pilgrim vs. The World.
Here's how.

#### First, the request

When you have some free time after browsing various places on the internet, you might want to get yourself some JSON.
To start this interaction, you would ask a server for some JSON using HTTP.

![Mr. Lee, you're needed back on set](/images/json-requests-and-the-2nd-evil-ex/needed-back-on-set.jpg)

#### Next, the response

Once the server recieves your request, it sends you JSON, as a normal HTTP response.
The only difference is that the headers contain type information letting you know that the content is JSON.

![Mr. Lee sends the JSON](/images/json-requests-and-the-2nd-evil-ex/message-sent.jpg)

### Now what?

So you now have some information, but it's not exactly JSON.
In fact, since it came from an HTTP request, it is literally just text:

```
HTTP/1.1 200 OK
Server: mrlee.example.com
Content-Type: application/json; charset=utf-ouch
Status: 200 YEAH OKAY

{
  "Mr.Lee": "The Best"
```

#### Let's parse it

Because this text is less useful to you than the information it contains, you need to parse it.

![Goad Lucas Lee into parsing JSON](/images/json-requests-and-the-2nd-evil-ex/goad-into-parsing.jpg)

Depending on the language you are using, parsing can look like many different things:

- .js: `theJson = JSON.parse(message);`
- .py: `the_json = json.loads(message)`
- .rb: `the_json = JSON.parse message`
- .go: `err := json.Unmarshal(message, &theJson)`

- .sp: `grind the rails` (.sp is scott pilgrim)

![Lucas Lee grinding the rails](/images/json-requests-and-the-2nd-evil-ex/grinding-rails.jpg)

Either way, you end up with an object, dictionary, hash, struct, or skateboarding evil ex containing your data.

#### What if it fails?

Not all blobs of text you are sent will end up being actual JSON.
When parsing JSON fails, the results can be catastrophic.

![Improperly formatted JSON parse explosion](/images/json-requests-and-the-2nd-evil-ex/parse-explosion.jpg)

### Moral of the story?

Sometimes you can defeat evil exes with improperly formatted JSON.
But that's less useful than actually getting information from other places.
