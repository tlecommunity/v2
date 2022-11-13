---
date: 2022-10-31
type: 'page'
---

# Founding an empire.

Founding an empire is done in one step using the `create` method.

# Empire Methods

The following methods are available from `/empire`.

## is_name_available

```json
{
  "name": "My Empire"
}
```

### name

The name of the empire to check.

### RESPONSE

Throws 1000 (Name not available)

If the name is valid and available it returns

```json
{
  "available": 1
}
```

## login

Accepts a hash of named arguments.

```json
{
  "name": "my_empire",
  "password": "highly_secret",
  "api_key": "3564d04f-8c36-4717-aa8d-e680502e0ed5"
}
```

### name (required)

Either the name of your empire, or the numeric ID of your empire.

### password (required)

The password can either be your main password, or your sitter password. (don't share
your main password with anyone)

### api_key (required)

Your client's unique API key, identifiying it from all other clients. See [ApiKeys](/api/ApiKeys) for details.

### RETURNS

If your credentials are correct, it returns the following.

```json
{
  "session_id": "3564d04f-8c36-4717-aa8d-e680502e0ed5",
  "status": {
    /* ... */
  }
}
```

**NOTE:** Once established, this session will stick around for up to 2 hours of inactivity.
Therefore, you need not login again if you still have a valid session.

Throws 1004 and 1005.

## logout

```json
{
  "session_id": "242d-967f-4fb7-8056-898638f44f7b"
}
```

Throws 1006.

### session_id

A session id.

### RETURNS

```json
{
  "logout": "1"
}
```

## fetch_captcha

Captchas are required for a number of purposes, including the call to the `create`
method. Display the resulting captcha in your form and then call `create` with
the user's response.

### RETURNS

```json
{
  "guid": "id-goes-here",
  "url": "'https://extras.lacunaexpanse.com.s3.amazonaws.com/captcha/id/id-goes-here.png"
}
```

## create

Creates a new empire and then returns an empire_id.

This is not the end of the story though. Then you must either create a
`update_species` for this empire and then `found` it, or just skip the
species part and `found` the empire.

Throws 1000, 1001, 1002, and 1014.

**NOTE:** If either `captcha_guid` or `captcha_solution` don't match what
the server is expecting it will throw a 1014 error, and the data portion
of the error message will contain new captcha information. You must use
this. A captcha cannot be used more than once.

Accepts a hash of named arguments

```json
{
  "name": "My Empire",
  "password": "Top S3crut",
  "password1": "Top S3crut",
  "captcha_guid": "e54caa40-730c-46d2-b002-244e27b055c6",
  "captcha_solution": "-5",
  "email": "me@mydomain.com",
  "facebook_uid": "",
  "facebook_token": "",
  "invite_code": "aca948e0-1468-3a51-9f2e-c688a484efd7"
}
```

### name

The name of the empire to create. Required.

### password

The password to log in to the empire. Must be between 6 and 30 characters.
Required unless you have a valid `facebook_uid` and `facebook_token`.
Still recommended even if you are authenticating using Facebook.

### password1

Retyping the password again. This must match `password` to succeed.

### captcha_guid

This must match the `guid` field returned by the `fetch_captcha` method.
Required.

### captcha_solution

This is the text typed in by the user as the solution of the captcha.
Required.

### email

The user's email address. It is not required, but is used for system vital
functions like password recovery.

### facebook_uid

A Facebook user id passed in through Lacuna's Facebook integration system.
Optional, but required with the use of `facebook_token`.

### facebook_token

A Facebook access token passed in through Lacuna's Facebook integration
system. Optional, but required with the use of `facebook_uid`.

### invite_code

A 36 character code that was sent to the user by a friend. It is usable once
only and will ensure that the friend gets a home planet that is relatively
close to their home planet.

### RETURNS

```json
    {
      empire_id => 123
    }
```

## found

Set up an empire on it's new home world. Once founded the species can no longer be
modified.

```json
{
  "empire_id": "123",
  "api_key": "3564d04f-8c36-4717-aa8d-e680502e0ed5"
}
```

### empire_id (required)

The empire ID returned from the `create` call.

### api_key (required)

The client's unique API key, identifying it from all other clients. See
[ApiKeys](/api/ApiKeys) for details.

### RETURNS

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "welcome_message_id": "1234",
  "status": {
    /* ... */
  }
}
```

The `welcome_message_id` is a message ID for a message in the inbox that starts
the tutorial. This is provided so that the user can be prompted to read the
message right away.

## update_species

Update the empire's species, Can only be called after `create` and before
`found`. Before or after that will throw an exception. If you have already
founded your empire then use `redefine_species`. See also
`get_species_templates`

```json
    {
      "name"                      : "Average",
      "description"               : "A race of average intellect, and weak constitution.',
      "min_orbit"                 : 3,
      "max_orbit"                 : 3,
      "manufacturing_affinity"    : 4,
      "deception_affinity"        : 4,
      "research_affinity"         : 4,
      "management_affinity"       : 4,
      "farming_affinity"          : 4,
      "mining_affinity"           : 4,
      "science_affinity"          : 4,
      "environmental_affinity"    : 4,
      "political_affinity"        : 4,
      "trade_affinity"            : 4,
      "growth_affinity"           : 4
    }
```

### name (required)

The name of the species. Limited to 30 characters, cannot be blank, and cannot contain @, &, <, >, or ;. Required.

### description (required)

The species description. Limited to 1024 characters and cannot contain < or >.

### min_orbit (required)

An integer between between 1 and 7, inclusive, where 1 is closest to the star. Each value between `species_min_orbit` and `species_max_orbit`, inclusive, count as a point toward the max of 45. `species_min_orbit` must be less than or equal to `species_max_orbit`.

### max_orbit (required)

An integer between between 1 and 7, inclusive, where 1 is closest to the star. Each value between `min_orbit` and `max_orbit`, inclusive, count as a point toward the max of 45. `max_orbit` must be greater than or equal to `min_orbit`.

### manufacturing_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages manufactured goods, such as ships.

### deception_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in spying.

### research_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in upgrading buildings.

### management_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in the speed of building.

### farming_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in food production.

### mining_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in mineral production.

### science_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in energy, propultion, and other technologies.

### environmental_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in waste and water management.

### political_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in managing population happiness.

### trade_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in freight handling.

### growth_affinity (required)

An integer between 1 and 7 inclusive, where 7 is best. Determines species advantages in colonization.

### RESPONSE

```json
{
  "update_species": 1
}
```

## get_invite_friend_url

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

### session_id

A session id.

### RESPONSE

Returns a URL that can be pasted into a blog, forum, or whatever to invite friends.

```json
{
  "status": {
    /* ... */
  },
  "referral_url": "http://servername.lacunaexpanse.com/#referral=XXXX"
}
```

## invite_friend

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "email": "friend1@example.com,friend2@somewhere.com",
  "custom_message": "Hi, come join me on this great game I found!"
}
```

### session_id (required)

A session id.

### email (required)

The email address of your friend, or a comma separated string of email addresses.

### custom_message (optional)

An optional text message that the user can type to invite their friend. This is the default message that will get sent if none is specified:

    I'm having a great time with this new game called Lacuna Expanse. Come play with me.

After the message, the user's empire name in the game, the friend code, and URI to the server will be attached.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "sent": [
    "you@example.com"
    /* ... */
  ],
  "not_sent": [
    {
      "address": "joe@blow.com",
      "reason": [1009, "Someone has already invited that user."]
    }
    /* ... */
  ]
}
```

## get_status

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

Returns information about the current state of the empire.

**NOTE:** You should probably **never** call this method directly, as it is a wasted call since the data it returns comes back in the status block of every relevant request. See ["Status" in Intro](/api/Intro#Status) for details.

### session_id (required)

A session id.

### RESPONSE

```json
     {
       "server" : { /* ... */ },
       "empire" : {
         "id" : "xxxx",
         "bodies" : {
           "colonies" : [
             # bodies are provided sorted by name already.
             { "id" : "xxxx", "name" : "/* ... */", "x": "#", "y": "#", "orbit": #, "type": "p35", "empire_name": "your name", "empire_id": 12345 },
             /* ... */
           ],
           "mystations" : [
             { "id" : "xxxx", "name" : "/* ... */", "x": "#", "y": "#", "orbit": #,, "type": "station", "empire_name": "your name", "empire_id": 12345 },
             /* ... */
           ],
           "ourstations" : [
             { "id" : "xxxx", "name" : "/* ... */", "x": "#", "y": "#", "orbit": #, "type": "station", "empire_name": "their name", "empire_id": 12346 },
             /* ... */
           ],
           "babies" : {
             "baby name" : {
               "alliance_id" : 3, // key doesn't exist if not in alliance
               "id" : 12355, // empire ID
               "has_new_messages" : 30,
               "bodies" : [
                 { "id" : "xxxx", "name" : "/* ... */", "x": "#", "y": "#", "orbit": #, "type": "p35", "empire_name": "their name", "empire_id": 12346 },
                 /* ... */
               ],
           },
           "another baby name" : {
             "has_new_messages" : 30,
             "id" : 12884,
             "bodies" : [
               { "id" : "xxxx", "name" : "/* ... */", "x": "#", "y": "#", "orbit": #, "type": "p35", "empire_name": "their name too", "empire_id": 12347 },
               /* ... */
             ],
           }
         }
       },
       "colonies" : {
         "id-goes-here" : "Earth",
         "id-goes-here" : "Mars"
       },
       "rpc_count" : 321, // the number of calls made to the server
       "insurrect_value" : 100000,
       "is_isolationist" : 1, // hasn't sent out probes or colony ships
       "name" : "The Syndicate",
       "status_message" : "A spy's work is never done.",
       "home_planet_id" : "id-goes-here",
       "has_new_messages" : 4,
       "latest_message_id" : 1234,
       "essentia" : 0,
       "next_colony_cost" : 100000,
       "next_station_cost" : 1000000,
       "planets" : {
         "id-goes-here" : "Earth",
         "id-goes-here" : "Mars",
         "id-goes-here" : "Death Star"
       },
       "tech_level"           : 20, // Highests level university has gotten to.
       "self_destruct_active" : 0,
       "self_destruct_date" : "",
       "stations" : {
         "id-goes-here" : "Death Star"
       },
       "primary_embassy_id" : 234567
     }
    }
```

Throws 1002.

## get_own_profile

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

View your own profile, which includes some things not shown on the `get_public_profile` method.

### session_id (required)

A session id.

### RESPONSE

```json
    {
      "private_profile" : {
        "id"               : 1234,
        "name"             : "My Empire",
        "description"      : "description goes here",
        "status_message"   : "status message goes here",
        "medals" : [
          {
            "id"           : 1234,
            "name"         : "Built Level 1 Building",
            "image"        : "building1",
            "date"         : "2013 01 31 12:34:45 +0600",
            "public" : 1,
            "times_earned" : 4
          },
              /* ... */
        },
        "city"             : "Madison",
        "country"          : "USA",
        "notes"            : "notes go here",
        "skype"            : "joeuser47",
        "player_name"      : "Joe User",
        "skip_happiness_warnings"  : 0,
        "skip_resource_warnings"   : 0,
        "skip_pollution_warnings"  : 0,
        "skip_medal_messages"      : 0,
        "skip_facebook_wall_posts" : 0,
        "skip_found_nothing"       : 0,
        "skip_excavator_resources" : 0,
        "skip_excavator_glyph"     : 0,
        "skip_excavator_plan"      : 0,
        "skip_spy_recovery"        : 0,
        "skip_probe_detected"      : 0,
        "skip_attack_messages"     : 0,
        "email"            : "joe@example.com",
        "sitter_password"  : "abcdefgh"                   # never give out your real password, use the sitter password
      },
      "status" : { /* ... */ }
    }
```

## edit_profile

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "description": "mostly harmless",
  "email": "me@example.com",
  "sitter_password": "topSecret",
  "status_message": "On Tour",
  "city": "London",
  "country": "England",
  "notes": "this is a reminder",
  "skype": "",
  "player_name": "Joe Bloggs",
  "public_medals": [
    233, 455
    /* ... */
  ],
  "skip_happiness_warnings": 0,
  "skip_resource_warnings": 0,
  "skip_pollution_warnings": 0,
  "skip_medal_messages": 0,
  "skip_facebook_wall_posts": 0,
  "skip_found_nothing": 0,
  "skip_excavator_resources": 0,
  "skip_excavator_glyph": 0,
  "skip_excavator_plan": 0,
  "skip_spy_recovery": 0,
  "skip_probe_detected": 0,
  "skip_attack_messages": 0
}
```

This will set one or more of your profile settings. For optional settings if you don't specify them
then the value will remain unchanged.

### session_id (required)

A session id.

### description (optional)

A description of the empire. Limited to 1024 characters and cannot contain < or >.

### email (optional)

An email address that can be used for system functions like password recovery. Must either resemble an email address or be empty.

### sitter_password (optional)

A password that can be safely given to account sitters and alliance members. Must be between 6 and 30 characters.

### status_message (optional)

A message to indicate what you're doing, how you're feeling, or other status indicator. Limited to 100 characters, cannot be blank, and cannot contain @, &, <, >, or ;.

### city (optional

An optional text string of the city in which the player resides. Limited to 100 characters and cannot contain @, &, <, >, or ;

### country (optional

An optional text string of the country in which the player resides. Limited to 100 characters and cannot contain @, &, <, >, or ;

### notes (optional

A text blob where the user can write down whatever they want to store in their account. Limited to 1024 characters and cannot contain @, &, <, >, or ;

### skype (optional

An optional text string of the username this player uses on skype. Limited to 100 characters and cannot contain @, &, <, >, or ;

### player_name (optional

An optional text string of the real name or online identity of this player. Limited to 100 characters and cannot contain @, &, <, >, or ;

### public_medals (optional

An array reference of medal ids that the user wishes to display in the public profile.

### skip_happiness_warnings (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages about unhappy citizens.

**WARNING**: These messages are there for your own protection. Turn off at your own risk.

### skip_resource_warnings (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages about a lack of resources to keep their buildings running.

**WARNING**: These messages are there for your own protection. Turn off at your own risk.

### skip_pollution_warnings (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages about excess waste causing pollution.

**WARNING**: These messages are there for your own protection. Turn off at your own risk.

### skip_medal_messages (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages about the medals they've earned.

### skip_facebook_wall_posts (optional

Defaults to 0. Set to 1 if the user no longer wants messages to be posted to their Facebook wall.

### skip_found_nothing (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages when excavators find nothing.

### skip_excavator_resources (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages when excavators find resources.

### skip_excavator_glyph (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages when excavators find glyphs.

### skip_excavator_plan (optional

Defaults to 0. Set to 1 if the user no longer wants to receive messages when excavators find plans.

### skip_spy_recovery (optional

Defaults to 0. Set to 1 if the user no longer wants to receive spy recovery messages. ("I'm ready to work. What do you need from me?")

### skip_probe_detected (optional

Defaults to 0. Set to 1 if the user no longers wants to receive messages when a probe is detected.

### skip_attack_messages (optional

Defaults to 0. Set to 1 if the user no longers wants to receive messages about attacks.

### RESPONSE

Edits properties of an empire. Returns the `get_own_profile` method. See also the `get_own_profile` and `get_public_profile` methods.

Throws 1005, 1009.

## get_public_profile

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "empire_id": 345
}
```

### session_id

A session id.

### empire_id

The id of the empire for which you'd like to retrieve the public profile.

### RESPONSE

```json
    {
      "public_profile" : {
        "id"               : 1,
        "name"             : "Lacuna Expanse Corp",
        "description"      : "We are the original inhabitants of the Lacuna Expanse.",
        "status_message"   : "Looking for Essentia.",
        "colony_count"     : 1,
        "medals" : [
          {
            "id"           : 1234,
            "name"         : "Built Level 1 Building",
            "image"        : "building1",
            "date"         : "2013 01 31 12:34:45 +0600",
            "public" : 1,
            "times_earned" : 4
          },
              /* ... */
        },
        "city"             : "Madison",
        "country"          : "USA",
        "skype"            : "joeuser47",
        "player_name"      : "Joe User",
        "last_login"       : "2013 01 31 12:34:45 +0600",
        "date_founded"     : "2013 01 31 12:34:45 +0600",
        "species"          : "Lacunan",
        "alliance" : {
          "id"             : "2",
          "name"           : "The Confederacy"
        },
        "known_colonies" : [
          {
            "id"           : "3434",
            "x"            : "1",
            "y"            : "-543",
            "name"         : "Earth",
            "image"        : "p12-3"
          },
          /* ... */
        ]
      },
      "status" : { /* ... */ }
    }
```

Throws 1002.

## send_password_reset_message

```json
{
  "empire_id": 213,
  "empire_name": "My Empire",
  "email": "me@example.com"
}
```

Parameters are all optional, select one of the three.

### empire_id (optional)

The unique id of the empire to recover.

### empire_name (optional)

The full name of the empire.

### email (optional)

The email address associated with an empire.

### RESPONSE

Starts a password recovery process by sending an email with a recovery key.

## reset_password

```json
{
  "reset_key": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "password1": "topSecret",
  "password2": "topSecret",
  "api_key": "3564d04f-8c36-4717-aa8d-e680502e0ed5"
}
```

Change the empire password that has been forgotten.

### reset_key (required)

A key that was emailed to the user via the `send_password_reset_message` method.

### password1 (required)

The password to log in to the empire. Required. Must be between 6 and 30 characters.

### password2 (required)

Retyping the password again. This must match `password1` to succeed.

### api_key (required)

Your client's unique API key, identifiying it from all other clients. See [ApiKeys](/api/ApiKeys) for details.

### RESPONSE

```json
{
  "session_id": "id-goes-here",
  "status": {
    /* ... */
  }
}
```

## change_password

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "password1": "topSecret",
  "password2": "topSecret"
}
```

### session_id (required)

A session id.

### password1 (required)

The password to log in to the empire. Required. Must be between 6 and 30 characters.

### password2 (required)

Retyping the password again. This must match `password1` to succeed.

### RESPONSE

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "status": {
    /* ... */
  }
}
```

## find

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "name": "Lacuna"
}
```

Search for all empires that start with `name`

### session_id (required)

A session id.

### name (required)

The name you are searching for. It's case insensitive, and partial names work fine. Must be at least 3 characters.

### RESPONSE

Returns a hash reference containing empire ids and empire names. So if you searched for "Lacuna" you might get back a result set that looks like this:

```json
{
  "empires": [
    {
      "id": "1",
      "name": "Lacuna Expanse Corp"
    },
    {
      "id": "365",
      "name": "Lacuna Pirates"
    }
  ],
  "status": {
    /* ... */
  }
}
```

## set_status_message

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "message": "Searching for glyphs."
}
```

### session_id (required)

A session id.

### message (required)

A message to indicate what you're doing, how you're feeling, or other status indicator. Limited to 100 characters, cannot be blank, and cannot contain @, &, <, >, or ;.

## set_boost

Spend 5 essentia, and increase one type of boost on all planets for 7 days.
If a boost is already underway, calling it again will 7 more days.

```json
{
  "type": "food",
  "weeks": 1
}
```

### type (required)

The type of boost, this is one of the following

- `ore`
- `water`
- `energy`
- `food`
- `happiness`
- `storage`
- `building`
- `ship_build`
- `ship_speed`
- `spy_training`

## weeks (optional)

If specified, the number of weeks of boost to apply.

If not specified it defaults to 1

## RESPONSE

```json
{
  "food_boost": "01 31 2010 13:09:05 +0600",
  "status": {
    /* ... */
  }
}
```

Throws 1011.

## get_boosts

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

### session_id (required)

A session id.

### RESPONSE

Shows the dates at which boosts have expired or will expire.
Boosts are subsidies applied to various resources using essentia.

```json
{
  "boosts": {
    "food": "2013 01 31 12:34:45 +0600",
    "ore": "2013 01 31 12:34:45 +0600",
    "energy": "2013 01 31 12:34:45 +0600",
    "water": "2013 01 31 12:34:45 +0600",
    "happiness": "2013 01 31 12:34:45 +0600",
    "storage": "2013 01 31 12:34:45 +0600",
    "building": "2013 01 31 12:34:45 +0600",
    "ship_build": "2013 01 31 12:34:45 +0600",
    "ship_speed": "2013 01 31 12:34:45 +0600",
    "spy_training": "2013 01 31 12:34:45 +0600"
  },
  "status": {
    /* ... */
  }
}
```

## enable_self_destruct ( session_id )

Enables a destruction countdown of 24 hours. Sometime after the timer runs out, the empire will vaporize.

### RESPONSE

```json
{
  "status": {
    /* ... */
  }
}
```

## disable_self_destruct)

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

Disables the self distruction countdown.

### session_id (required)

A session id.

### RESPONSE

```json
    {
       "amount" : /* ... */,
       "status" : { /* ... */ }
    }
```

## redeem_essentia_code

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "code": "3564d04f-8c36-4717-aa8d-e680502e0ed5"
}
```

Redeems an essentia code and applies the essentia to the empire's balance.

### session_id (required)

A session id.

### code (required)

A 36 character string that was sent to the user via email.

### RESPONSE

```json
{
  "status": {
    /* ... */
  }
}
```

## get_redefine_species_limits

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

Defines the extra limits placed upon a user that want's to redefine their species.

### session_id (required)

A session id.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "essentia_cost": 100, // cost to redefine the species
  "species_max_orbit": 2, // maximum settable orbit
  "species_min_orbit": 5, // minimum settable orbit
  "species_min_growth": 4, // minimum for growth affinity
  "can": 0, // whether or not they can redefine their species
  "reason": "You have already redefined your species in the past 30 days."
}
```

## redefine_species

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e",
  "name": "Average",
  "description": "Not specializing in any area, but without any particular weaknesses.",
  "min_orbit": 3,
  "max_orbit": 3,
  "manufacturing": 4,
  "deception": 4,
  "research": 4,
  "management": 4,
  "farming": 4,
  "mining": 4,
  "science": 4,
  "environmental": 4,
  "political": 4,
  "trade": 4,
  "growth": 4
}
```

Allows a user to spend essentia and redefine their species affinities, name, and description.

### session_id (required)

A session id.

### For all other parameters, see `create` method.

### RESPONSE

See also `redefine_species_limits`.

```json
{
  "status": {
    /* ... */
  }
}
```

**WARNING:** Once this is done it cannot be redone for 1 month, so make sure the user is aware of this and prompt them appropriately before submitting the request.

### session_id

A session id.

### params

## get_species_stats

Returns a list of the stats associated with an empire's species as it was originally created. An empire can only view it's own species stats through this method.

```json
{
  "session_id": "9eea6721-3326-4c1f-817d-a4e82b54818e"
}
```

### session_id (required)

A session id.

### RESPONSE

````json
    {
      "species" : {
   Returns an array ref of species templates that can be used to help the user populate the form for C<update_species>.

    [
       {
          "name" : "Average",
           "description" : "A race of average intellect, and weak constitution.',
           "min_orbit" : 3,
           "max_orbit" : 3,
           "manufacturing_affinity" : 4,
           "deception_affinity" : 4,
           "research_affinity" : 4,
           "management_affinity" : 4,
           "farming_affinity" : 4,
           "mining_affinity" : 4,
           "science_affinity" : 4,
           "environmental_affinity" : 4,
           "political_affinity" : 4,
           "trade_affinity" : 4,
           "growth_affinity" : 4
       },
       /* ... */
    ]

## view_authorized_sitters

Returns the currently authorized sitters for this baby.

```json
    {
       "status" : { /* ... */ },
       "sitters" : [
         {
           "id" : 12345,
           "name" : "Some Empire",
           "expiry" : "2015-10-10 17:20:03"
         },
         /* ... */
       ]
    }
````

## authorize_sitters ( session_id, options )

Authorizes other empires to babysit your account. Each authorisation will
be created if needed, and authorized for the full server-defined amount of
time.

Returns view of authorized sitters (see view_authorized_sitters) plus any
rejected IDs.

```json
    {
       "status" : { /* ... */ },
       "auths" : [
         {
           id => /* ... */,
           name => /* ... */
         },
         /* ... */
       ],
       "rejected_ids" : [ 57, "No Such Empire", /* ... */ ],
    }
```

### session_id

A session id.

### options

One or more of the following options:

#### allied

If true, all allies are automatically selected.

#### alliance

The name of another alliance all of whom are automatically selected.

#### alliance_id

The ID of another alliance all of whom are automatically selected.

#### empires

An array of IDs and/or names of specific empires being authorized.

#### revalidate_all

A quick method for selecting all currently-authorized empires to
extend their authorization period.

## deauthorize_sitters ( session_id, options )

Remove sitters from being permitted to sit this account.

### session_id

A session id.

### options

One or more of the following options:

#### empires

An array of IDs (not names) of specific empires being removed.

```

```
