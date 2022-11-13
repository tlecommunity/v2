---
date: 2022-10-31
type: 'page'
---

# API Keys

An API key is a string that uniquely identifies a client (like the web client vs the iPhone client) to the server.

# API Key FAQ

## Why are API keys needed?

Client keys allow us to track which clients are being used for what purpose. For example, if we find
that people are using their own bots for a certain type of function, we may decide that just needs
to become a game feature. Or if we find that the iPhone client is being used more than the web
client, then maybe there's something wrong with the web client, or maybe it's time to build an Android client.

## Where in the API are API keys used?

They are only used on methods that create a session, such as `login` and `found` in [Empire](/api/Empire).

## How do I get an API key?

You can register for an API key by going to https://servername.lacunaexpanse.com/apikey. That's the API Key Console.

## Are API keys specific to a server?

Yes.

## Since API keys are specific to a specific server how am I supposed to write a client for multiple servers?

Register a key on each server, and then depending on which server a user selects in your app, use the right
key for that server.

## Are API keys a security feature?

No they are not. The API keys are only used to track which client is using which features of the API. They are
used solely to help us determine strengths and weaknesses in our own client offerings, and since we're opening
this up to you, it can help you in the same way.

## If I distribute my software, how do I make sure nobody can look at my usage stats except me?

It's true that your API key is public. That's why when we generate your public API key, we also generate a
private one that you should keep secret and secure. Then you'll be the only one who can see your usage stats.

## What's the difference between a public key and a private key?

The public key is used in your application when making calls to the server.

The private key is used when you want to check the stats of your public key on the API Key Console.

## There aren't many stats displayed, is there a way I can see more?

We weren't sure how many people would actually want to use this feature so we haven't put a lot of time into it.
We're tracking a lot of things, we're just not displaying much. If there's something you want to see, talk about
that in the Developers Forum ([http://community.lacunaexpanse.com/forums/developers](http://community.lacunaexpanse.com/forums/developers)). Don't bother asking for
specific user information. That would be a privacy violation, and we're not about to violate our user's privacy.

## I don't care to see any stats, I just want to write a simple script and I don't want to use a key.

There is an anonymous public key just for this purpose. Just pass the word `anonymous` where you would normally
put an API key. Be warned though, this is truly anonymous, so if you change your mind later all that trend data
will be lost.
