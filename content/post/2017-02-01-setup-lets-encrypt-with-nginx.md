+++
draft = false
tags = ["nginx", "let's encrypt", "how to"
]
date = "2017-02-01T12:53:14-05:00"
title = "Setup Let's Encrypt with NGINX"
url = "post/setup-lets-encrypt-with-nginx/"

+++

This is a tutorial about getting your website setup to use TLS.
TLS is important, and if you're here you probably already know why.
But [here's a wiki page about it just in
case](https://en.wikipedia.org/wiki/Transport_Layer_Security).

Before we start setting things up, let's first talk about scope.
This article isn't trying to answer every single aspect of setting up a server
with [NGINX](https://nginx.org/en/docs/) and [Let's
Encrypt](https://letsencrypt.org/).
But it is trying to combine advice from a series of other guides in order to
give you a complete and somewhat more up-to-date guide on how to use these
technologies.

You won't need to understand how all the pieces work to still get things
working.
And at the end, you'll have a website that is secured with TLS.

With that, let's quickly look at what **won't be covered**:

# Nope

1. Getting a domain name
2. Getting a server
3. Pointing the domain at the server
4. Making a website
5. [General NGINX setup](https://nginx.org/en/docs/)
6. Understanding certificates
7. Understanding the certificate issuing process

If you're unfamiliar with any of the above, you'll need to find a guide
elsewhere to learn more about them.
If I find any good guides I'll link them here later, like the NGINX guide linked
in point 5.

Now we can talk about things that are in this post:

# Yup

1. [Installing Certbot, Let's Encrypt's recommended way to handle
   certificates](#installing-certbot)
2. [Setting up Let's Encrypt's initial configuration](#configuring-lets-encrypt)
3. [Setting up NGINX for the initial challenge response](#configuring-nginx)
4. [Testing and running Certbot](#running-certbot)
5. [Updating NGINX to use the generated certificate](#reconfiguring-nginx)
6. [Automating Certbot](#automating-certbot)
  1. [Settng up cron (if necessary)](#maybe-cron)
7. [Checking again later](#checking-later)
8. [Further reading](#further-reading)
9. [Sources](#sources)

So let's get to it.

## Installing Certbot<a name="installing-certbot"></a>

Certbot itself has [really good installation docs](https://certbot.eff.org/).
Just use the two provided drop down menus to find your software and system.
For a complete example, I'm using NGINX on Debian Jesse, which links to
[these instructions](https://certbot.eff.org/#debianjessie-nginx).

The instructions tell me that I need to enable the Debian Jesse backports
repository.
Luckily, Certbot also links to [the instructions for
that](https://backports.debian.org/Instructions/).
Long story short, add this line:
```
deb http://ftp.debian.org/debian jessie-backports main
```
to your `sources.list` file located in `/etc/apt/`

Then run `apt-get update` (`sudo` may be required).

Finally, install Certbot by running `apt-get install certbot -t
jessie-backports` (again `sudo` may be required).
You should now have a `certbot` command.

## Configuring Let's Encrypt<a name="configuring-lets-encrypt"></a>

The next couple of steps come from [NGINX's own wonderful
docs](https://www.nginx.com/blog/free-certificates-lets-encrypt-and-nginx/) on
using Let's Encrypt, as well as [Certbot's config
docs](https://certbot.eff.org/docs/using.html#configuration-file).

First off, we need a configuration for generating our Let's Encrypt certificate.
This sets up things like the domains we generate the certificate for, as well as
things like the certificate key size and method of authentication.
It'll also let us figure out what we did later (something that I've found
incredibly useful in writing this blog post :)

My configuration for [quine.space](https://www.quine.space) is documented and
looks like this:

```sh
# Domains to get the cert for, comma separated
domains = www.quine.space, quine.space

# Set the key size (2048 is the default, but this makes it explicit)
rsa-key-size = 2048

# The renewal reminder email will be sent here
email = you@your-domain.example.com

# ncurses is used by default, this turns it off
text = True

# The method of authentication
authenticator = webroot
webroot-path = /var/www/letsencrypt
```

You want to save this somewhere where you can find it again.
Either make a `letsencrypt` folder in your home directory, or make a `configs`
folder in `/etc/letsencrypt/`.
I personally saved the config above here:
`/etc/letsencrypt/configs/quine.space.conf`.

Now lemme say some stuff about the contents of this file.

The `domains = ...` section is a comma separated list of the domains you want
your certificate to cover.
Subdomains like `www.example.com` are different than just `example.com`, so you
need to list them all.

The `rsa-key-size = ...` is the length of the RSA key for your certificate.
For now, you probably want the default of `2048`, because it's still considered
secure, and it's faster than larger keys.
Additionally, key size doesn't linearly add security, so a key of 4096 bits is
[only 16% more secure than a key of
2048 bits](https://www.yubico.com/2015/02/big-debate-2048-4096-yubicos-stand/).
Besides, [not everything works with 4096 bit keys, and they're
slower](https://certsimple.com/blog/measuring-ssl-rsa-keys).

The `email = ...` doesn't have anything to do with your key, but it will allow
Let's Encrypt to email you when your certificate is expiring, if it hasn't been
renewed yet.

`text = True` turns off the UI that Certbot has.
This only has an effect when creating the certificate initially, so setting it
is optional.

The `authenticator = ...` and `webroot-path = ...` are the method of
authentication used to prove that you have the domain.
The available methods are listed
[here](https://certbot.eff.org/docs/using.html#getting-certificates-and-choosing-plugins).
We're going to use `webroot` because it can be used with any type of web server,
and doesn't require either port 80 or 443 to be free.
I didn't use the `--nginx` plugin because I couldn't get it to work initially,
and "needed" to update my certificate quickly, as the previous one had expired.

Another key point about `webroot-path` is that this is the location that NGINX
will use to serve a file that it will use to authenticate our certificate.
So the `www-data` user will need access to this folder to serve the information.

## Configuring NGINX<a name="configuring-nginx"></a>

In order to authenticate our certificate, we need to modify the NGINX config to
allow Let's Encrypt to access a temporary file.
This'll involve an update to whatever NGINX configuration you have now.
For [quine.space](https://www.quine.space), I use NGINX only for the TLS termination,
and proxy the traffic locally.
So here's a sample configuration with some explanation, but your config will
vary from what's shown here.

```sh
# Lots of comments at the top of this file normally
# The part we care about starts with "server"
server {
  listen 80;
  server_name quine.space www.quine.space;

  # The initial letsencrypt setup
  location /.well-known/acme-challenge {
    root /var/www/letsencrypt;
  }

  # Your config is down here, and might include one or both of the following:
  #
  # Regular proxy passing
  location / {
    proxy_pass http://127.0.0.1:3000;
  }
  #
  # Maybe a rewrite to move people to https?
  rewrite ^ https://$server_name$request_uri? permanent;
}
```

The key to this file is the initial Let's Encrypt setup.
```
location /.well-known/acme-challenge {
  root /var/www/letsencrypt;
}
```

You may remember `/var/www/letsencrypt`.
It was in our original Certbot config, and it's the location from which Certbot
will check that we control this domain.

**An aside**: We currently have the check here, on port 80 and unencrypted,
because we don't yet have a certificate.
Later, we can actually put this configuration in our TLS config (port 443), and
use our current certificate to secure the connection in checking for our new
one.

After you've setup NGINX, test the config with `nginx -t` and reload it with
`nginx -s reload`.
As always, you might need `sudo` for those.

## Testing and running Certbot<a name="running-certbot"></a>

Now that we have everything setup, we can do a test run of Certbot to make sure
it works before we actually run it to get our certificates!

Do this
```
certbot certonly --dry-run --config /location/of/config.conf
```
making sure to put the path to your config after the `--config` flag.

When you do that, the output should look something like this:

```sh
$ certbot certonly --dry-run --config /etc/letsencrypt/configs/quinespace.conf
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Starting new HTTPS connection (1): acme-staging.api.letsencrypt.org
Performing the following challenges:
http-01 challenge for www.quine.space
http-01 challenge for quine.space
Using the webroot path /var/www/letsencrypt for all unmatched domains.
Waiting for verification...
Cleaning up challenges
Generating key (2048 bits): /etc/letsencrypt/keys/0001_key-certbot.pem
Creating CSR: /etc/letsencrypt/csr/0001_csr-certbot.pem

IMPORTANT NOTES:
 - The dry run was successful.
```

If your dry run is successful, go ahead and run the same command without the
`--dry-run`.
If that works, you should see a message under `IMPORTANT NOTES:` that tells you
where your certificate was saved.
We'll need that in a second.

## Updating NGINX to use the generated certificate<a name="reconfiguring-nginx">
</a>

Now that we have our certificates, we can setup NGINX to use them!

You probably want to change your server config for port 80 to no longer include
serving the challenge response, and to now forward traffic to port 443.

So remove:
```sh
location /.well-known/acme-challenge {
  root /var/www/letsencrypt;
}
```

And maybe add something like:
```
rewrite ^ https://$server_name$request_uri? permanent;
```

Then add the ssl certificates to your 443 section, as well as the challenge
response url that used to be under the port 80 section.

```sh
server {
  listen 443;
  server_name quine.space www.quine.space;

  ssl on;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_certificate /etc/letsencrypt/live/www.quine.space/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/www.quine.space/privkey.pem;

  # Let's Encrypt challenge response route
  location /.well-known/acme-challenge {
          root /var/www/letsencrypt;
  }

  # The rest of your config goes here:
  # ...
}
```

where the `ssl_certificate` and `ssl_certificate_key` lines point to the
location you saw above under `IMPORTANT NOTES:`.
If you don't remember where that was, don't worry too much.
It's probably in `/etc/letsencrypt/live/<name_of_your_domain>/`.

Don't forget to reload the nginx configuration after you've changed your config.

`nginx -t` and `nginx -s reload`.

After all of that, test to make sure you can use the new configuration to renew
your certificates.
Do this by running `certbot renew --dry-run`.
If you eventually see part of a message say `Congratulations, all renewals
succeeded.`, then you're good to go.

## Automating Certbot<a name="automating-certbot"></a>

Now that everything is setup properly, we need to automate the renewal process.

For Debian Jesse, this is super easy, as Certbot has already setup a cron for us
in `/etc/cron.d/certbot`.
If you look at that file, you'll see it already has a cron command setup to run
twice a day.
We just need one little tweak to make things work for us.
That is, adding a `--post-hook` to the `certbot renew` command so that our
server reloads once we have the new certificates in place.
So add this to the end of the line after `certbot renew`: `--post-hook "service
nginx reload"`.

Oh, and why run this command twice a day, when we only need to renew the
certificate once every three months?
Well, Let's Encrypt actually suggests this.
Their API rate limit applies to the actual certificate generation, not to
attempts to renew it.
And the renewal only generates the new certificate if the current certificate
will expire in 30 days.
You could modify this timing if you want, but it's no problem to leave it as it
is.

### Maybe cron?<a name="maybe-cron"></a>

So this section exists because Certbot might not have setup a cron for you
already.
If that's the case, you want your command to look something like this (all on
one line):

```sh
0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(3600))' && certbot renew --post-hook "service nginx reload"
```

To ensure it'll work, you'll also want to setup a shell and path that'll work.
Earlier in the cron file (or crontab), include these:

```
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
```

Also make sure you have perl installed.
But if you don't, you can just remove the perl section: `&& perl -e 'sleep
int(rand(3600))'`.

## Checking later<a name="checking-later"></a>

Once you've got this all setup, you'll want to make sure your certificate is
renewing properly.
Mark your calendar for 2 months and a couple days out from when you first did
this.
Then check your certificate in the web browser.
It should have a new "Begins On" date.

If it doesn't, some debugging is in order.
You can see what cron issues you're having by [turning on cron
logging](https://askubuntu.com/questions/56683/where-is-the-cron-crontab-log#answer-121560).
Remember, it's fine to run the `certbot renew` command via cron every 5 minutes
or so while you're debugging.
Just make sure to turn it back to twice a day or so once you're done :)

## Further Reading<a name="further-reading"></a>

All of the above is just the **how** of getting setup.
It is not the **how** of the way things work, nor the **how** of best
practices.

I don't have a good source for learning how these things work.
But I do know at least one good source for checking best practices, and that's
[SSL Labs](https://www.ssllabs.com/).
After going through this process myself, I used their [SSL testing
tool](https://www.ssllabs.com/ssltest/) to improve the configuration of my NGINX
server.
I recommend that you do too.
There is so much out there to know that it's especially hard to know it all
yourself unless this is your full time job.

## Sources<a name="sources"></a>

Here are some of the sources used to compile this information.
Some of them may have been linked in line, but all of them were used at one
point or another.

1. https://www.nginx.com/blog/free-certificates-lets-encrypt-and-nginx/
2. https://gist.github.com/xrstf/581981008b6be0d2224f
3. https://certbot.eff.org/
4. https://backports.debian.org/Instructions/
5. https://botleg.com/stories/https-with-lets-encrypt-and-nginx/
6. https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04
