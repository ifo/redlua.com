+++
title = "https.quine.space: A Simple TLS Server Written in Go"
url = "post/https-quine-space-a-simple-tls-server-written-in-go/"
date = 2018-04-15T15:14:23-04:00
tags = ["25 5", "how to", "golang", "tls"]
draft = true
+++

This is the second project in my [current 25:5 process](/post/starting-25-5),
which you can follow with the [25:5 tag](/tags/25-5/).
This post is primarily about how to do https in Golang, and not really about the
project itself.

## https.quine.space

This project is live!
And it has been for a while, honestly.
It's fairly simple, and most of the necessary information came from a single
blog post on [gopher academy][].

If you want to see the source code, just go to [https.quine.space][]!
Though I guess there's also a
[github](https://github.com/ifo/quine.space/blob/master/https/https.quine.space.go).

## So anyway, what's all this do?

I'm going to gloss over some of the details, like the Go basics of package and
imports, and mostly talk about the specifics of https and Go servers.

Let's go through the setup.

```go
httpPort := os.Getenv("HTTP_PORT")
httpsPort := os.Getenv("HTTPS_PORT")
```
These lines are setting up bits of configuration.
Normally, your HTTP port is 80, and your HTTPS port is 443.
But if you're testing locally, you may want those to be different, so we make
them configurable.
Having a default would be nice, but that's more work, and this is somewhat
intended to be a reference, so keeping it brief is best.

```go
secretDir := os.Getenv("SECRET_DIR")
autocertWhitelist := os.Getenv("HOST_WHITELIST")
if autocertWhitelist == "" {
	autocertWhitelist = "quine.space"
}

// Setup and handle autocert - a.k.a. Let's Encrypt
m := &autocert.Manager{
	Cache:      autocert.DirCache(secretDir),
	Prompt:     autocert.AcceptTOS,
	HostPolicy: autocert.HostWhitelist(autocertWhitelist),
}
```

The secret dir is just where the cert will be stored on the file system, and the
whitelist ensures that you don't attempt to request a certificate for a domain
that isn't yours.
So we set this as "quine.space", and pass all of that to [the
manager](https://godoc.org/golang.org/x/crypto/acme/autocert), which will
eventually be inserted into the GetCertificate section of a standard TLSConfig.

```go
// Redirect to https
httpRedirectHandler := http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Connection", "close")
	url := "https://" + req.Host + req.URL.String()
	http.Redirect(w, req, url, http.StatusTemporaryRedirect)
})

// Run the http autocert server with https redirect fallback
go http.ListenAndServe(":"+httpPort, m.HTTPHandler(httpRedirectHandler))
```

This section sets up a redirect from regular http to https.
The reason we need this is that anyone who attempted to go to
http://https.quine.space would get a 404, because the server hasn't been told to
do anything with those requests.
Instead, now that we have this, they'll simply be redirected to the same page
but over https instead of http.
The `go` keyword before our `http.ListenAndServe` ensures that this redirect
server runs, but allows us to continue to setup our https server afterwards.

```go
// TLS Config based on https://blog.gopheracademy.com/advent-2016/exposing-go-on-the-internet/
tlsConfig := &tls.Config{
	CipherSuites: []uint16{
		tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
		tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
		tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,
		tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,
		tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
		tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
	},
	CurvePreferences: []tls.CurveID{
		tls.CurveP256,
		tls.X25519,
	},
	// GetCertificate provided by the autocert manager
	GetCertificate:           m.GetCertificate,
	PreferServerCipherSuites: true,
	MinVersion:               tls.VersionTLS12,
}
```

Admittedly, this section had the most copying from the [gopher academy blog
post][gopher academy].
I don't know most of what is going on, other than we're setting up which types
of cyphers and curves and TLS versions we're cool with using.

But I *do* know that you'll want to confer with a cryptographer about it.
Regularly, if you want to use this for a real system.

Though the thing I can point out here is the `GetCertificate` section.
`m.GetCertificate` comes from the autocert manager we setup earlier, and is the
magic behind getting a real certificate from [Let's Encrypt][], or whatever
other ACME based certificate authority you want (though I don't personally know
of any others).

```go
// Setup the TLS server
srv := &http.Server{
	Addr:         ":" + httpsPort,
	ReadTimeout:  5 * time.Second,
	WriteTimeout: 10 * time.Second,
	IdleTimeout:  120 * time.Second,
	TLSConfig:    tlsConfig,
	Handler: http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		fmt.Fprintf(w, quine, backtick+quine+backtick, backtick)
	}),
}
```

The final configuration piece!
This is the actual https server configuration.
Most of the timeout information also comes from the referenced blog post.
But the important part is, we've added the `tlsConfig` we created above and the
`httpsPort` configuration (which is usually 443), to ensure this is a TLS
server.

**note**: You may have noticed that `quine` and `backtick` haven't yet been
defined.
That's true, and relates specifically to [quine.space][] things.
If you want this example to actually work, just replace everything after the `w`
in the `fmt.Fprintf` with a string of your choice, and it'll all work.

```go
log.Println(srv.ListenAndServeTLS("", ""))
```

The last step is to run `ListenAndServeTLS` instead of the regular
`ListenAndServe`.
We pass in empty values for the `certFile` and `keyFile`, because the
`TLSConfig.GetCertificate` handles that stuff for us.

## What's all the rest of the stuff at [https.quine.space][]?

Because reasons (a.k.a. for fun), things on [quine.space][] will show the source
code used to serve the page you see.
In order to do that, I essentially have to create a string which is _almost
exactly_ the program already, and print it out.
So the undefined variables I mentioned before, `quine` and `backtick`?
They're essentially just the entire program again, plus the ability to print it
out.
You don't actually _need_ any of that if all you want to do is run a TLS server.

## Anything else you'd like to share?

Yeah!

The first time someone connects to this server, the `autocert` that was setup
will have to talk to [Let's Encrypt][] and actually get the certificate.
For whatever reason, this code will fail to serve the page when that occurs.
So the _very first_ person to look at this site will see nothing.
But everyone after that should be fine :)

Also, though I've linked to it several times in this post already, I wouldn't
have been able to write this without the [gopher academy][] blog post.
It was an essential resource for this project and this post.

## Next project: ʅʕ•ᴥ•ʔʃ

There are three projects left:

- kubernetes raspberrypi cluster
- bott pilgrim - a twitter bot that quotes Scott Pilgrim vs. The World
- a redis hosting site

All of them have been started in some way, but none of them are particularly far
along.
So I'm not sure which one will be next, but I know I'll write something up about
it, and will likely have little posts in between for smaller learnings.

[quine.space]: https://quine.space
[https.quine.space]: https://https.quine.space
[gopher academy]: https://blog.gopheracademy.com/advent-2016/exposing-go-on-the-internet/
[Let's Encrypt]: https://letsencrypt.org/
