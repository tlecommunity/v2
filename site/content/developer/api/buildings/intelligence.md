---
date: 2022-10-31
type: 'page'
---

# Intelligence Methods

Intelligence Ministry is accessible via the URL `/intelligence`.

The Intelligence Ministry is where you build and control your spies.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

```json
{
  "status": {
    /* ... */
  },
  "building": {
    /* ... */
  },
  "spies": {
    "maximum": 5,
    "current": 1,
    "in_training": 1,
    "training_costs": {
      "food": 100,
      "water": 120,
      "energy": 20,
      "ore": 5,
      "waste": 10,
      "time": 60
    }
  }
}
```

## train_spy ( session_id, building_id, [ quantity ])

Allows you to train more spies.

```json
{
  "status": {
    /* ... */
  },
  "trained": 3,
  "not_trained": 2,
  "reason_not_trained": {
    "code": 1011,
    "message": "Not enough food to train a spy."
  }
}
```

The only reason `not_trained` might be over 0 is if you specify training more spies than you have resources to spend in which case the reason_not_trained block will be included.

Throws 1013, 1009.

### session_id

A session id.

### building_id

The unique id of your Intelligence Ministry.

### quantity

An integer between 1 and 5. Defaults to 1.

## view_spies ( session_id, building_id, [ page_number ] )

Returns the list of spies you have on your roster.

```json
{
  "status": {
    /* ... */
  },
  "spies": [
    {
      "id": "id-goes-here",
      "name": "Jason Bourne",
      "assignment": "Idle",
      "possible_assignments": [
        {
          "task": "Idle",
          "recovery": 0,
          "skill": "none"
        },
        {
          "task": "Counter Espionage",
          "recovery": 0,
          "skill": "*"
        },
        {
          "task": "Security Sweep",
          "recovery": 14400, // in seconds
          "skill": "intel"
        }
        /* ... */
      ],
      "level": 9,
      "politics": 0, // experience in handling happiness
      "mayhem": 20, // experience in handling missions involving murder and destruction
      "theft": 40, // experience in handling missions involving stealing items
      "intel": 33, // experience in handling missions involving information and spies
      "offense_rating": 570,
      "defense_rating": 150,
      "assigned_to": {
        "body_id": "id-goes-here",
        "name": "Earth",
        "x": 40,
        "y": -71
      },
      "based_from": {
        "body_id": "id-goes-here",
        "name": "Earth",
        "x": 40,
        "y": -71
      },
      "is_available": 1, // can be reassigned
      "available_on": "01 31 2010 13:09:05 +0600", // if can't be reassigned, this is when will be available
      "started_assignment": "01 31 2010 13:09:05 +0600",
      "seconds_remaining": 45,
      "mission_count": {
        "offensive": 149,
        "defensive": 149
      }
    }
    /* ... */
  ],
  "spy_count": 12
}
```

Take a look at the `assign_spy` method below for assignment descriptions.

**NOTE:** If a spy is already recovering from a particular assignment, then `possible_assignments` will return only that one assignment and the recovery time will be however much recovery time is remaining.

### session_id

A session id.

### building_id

The unique id of your Intelligence Ministry.

### page_number

Defaults to 1. An integer representing which page to view. Shows 30 spies per page.

## view_all_spies ( session_id, building_id )

Returns the list of spies you have on your roster from that Intelligence Ministy. Otherwise identical to view_spies.

## subsidize_training ( session_id, building_id )

Will spend 1 essentia per spy to complete the training of all spies immediately. Returns `view`.

Throws 1011.

### session_id

A session id.

### building_id

The unique id of the Intelligence Ministry.

## burn_spy ( session_id, building_id, spy_id )

Allows you to eliminate one of your spies from your payroll.

```json
{
  "status": {
    /* ... */
  }
}
```

Throws 1002, 1010

### session_id

A session id.

### building_id

The unique id of your Intelligence Ministry.

### spy_id

The unique id of the spy you wish to burn.

## name_spy ( session_id, building_id, spy_id, name )

Set the name of the spy. Returns:

```json
{
  "status": {
    /* ... */
  }
}
```

Throws 1002, 1005, 1013.

## name_spies ( { session_id: session_id, building_id: building_id, prefix: "p", suffix: "s", rename_null_only: bool } )

Sets the name of (almost) all spies. The new name of the spy will be of the form "p ## s" if both prefix and suffix are given, "p ##" if only prefix is given, and "## s" if only suffix is given.

If rename_null_only is given, only spies currently named "Agent Null" will be renamed. If you want some spies set to specific values, and the rest can be given generic names, you can use this flag.

Note that spies that already have valid names according to the prefix and/or suffix given will not be renamed (unless they are duplicates). If you've already got spy "p 08 s", that spy will not get renamed as long as "p" and "s" are given as prefix and suffix, respectively, and no new spy will get that name until the current "p 08 s" is retired and replaced.

Returns `view_all_spies` plus a `renamed` key with the count of spies renamed.

### session_id

A session id.

### building_id

The unique id of the intelligence building.

### spy_id

The unique id of the spy you wish to train.

### name

The name you'd like to set for the spy. The name cannot contain @, <, //, &, ; or profanity, and must be at least 1 character long.

## assign_spy ( session_id, building_id, spy_id, assignment )

Set a spy on a new task.

```json
{
  "status": {
    /* ... */
  },
  "mission": {
    "result": "Failure",
    "message_id": "id-goes-here",
    "reason": "I'm under heavy fire over here!"
  },
  "spy": {
    "id": "id-goes-here",
    "name": "Jason Bourne",
    "assignment": "Idle",
    "possible_assignments": [
      {
        "task": "Idle",
        "recovery": 0,
        "skill": "none"
      },
      {
        "task": "Counter Espionage",
        "recovery": 0,
        "skill": "*"
      },
      {
        "task": "Security Sweep",
        "recovery": 14400, // in seconds
        "skill": "intel"
      }
      /* ... */
    ],
    "level": 9,
    "politics": 0, // experience in handling happiness
    "mayhem": 20, // experience in handling missions involving murder and destruction
    "theft": 40, // experience in handling missions involving stealing items
    "intel": 33, // experience in handling missions involving information and spies
    "offense_rating": 570,
    "defense_rating": 150,
    "assigned_to": {
      "body_id": "id-goes-here",
      "name": "Earth"
    },
    "is_available": 1, // can be reassigned
    "available_on": "01 31 2010 13:09:05 +0600", // if can't be reassigned, this is when will be available
    "started_assignment": "01 31 2010 13:09:05 +0600",
    "seconds_remaining": 45
  }
}
```

The mission block allows you to give immediate feedback to the player. The `result` types that can be sent back are:

- Accepted

  This is provided when no immediate mission occurs. For example, if you set a spy to "Idle" or "Counter Espionage".

- Success

  This means a mission has occurred and came out in favor of the spy.

- Bounce

  This means a mission started, but was foiled and neither side won.

- Failure

  This means a mission occurred, but went so poorly that the defense got the upper hand and bested you.

The `reason` provides a message in sentence form about why a spy won or lost a mission. This message is related to the success or failure, not any outcome that results from that success or failure.

The `message_id` refers to a message in the [Inbox](/api/Inbox). Providing this ID allows you to pop open the inbox to a specific message to display to the user. The message will tell you what the outcome of the mission is if any. Not all missions will provide a message_id.

### session_id

A session id.

### building_id

The unique id of your Intelligence Ministry.

### spy_id

The unique id of the spy you wish to assign.

### assignment

This can be either a hash (object) or a string. If it's a string, it is
treated as a hash whose sole key is `assignment` and the value is the string
given. If it's a hash, it accepts the following keys:

- assignment

  A string containing the new assignment name. These are the possible assignments:

  - Idle

    Don't do anything.

  - Bugout

    Only visible on non-home planets. Immediately has agent go to their home base via spypod.

  - Counter Espionage.

    Passively defend against all attackers.

  - Security Sweep

    Round up attackers.

  - Intel Training

    Train in Intelligence skill

  - Mayhem Training

    Train in Mayhem skill

  - Politics Training

    Train in Politics skill

  - Theft Training

    Train in Theft skill

  - Political Propaganda

    Give happiness generation a boost. Especially effective on unhappy colonies, but hastens an agent toward retirement. Only usuable on owned planets.

  - Gather Resource Intelligence

    Find out what's up for trade, what ships are available, what ships are being built, where ships are travelling to, etc.

  - Gather Empire Intelligence

    Find out what is built on this planet, the resources of the planet, what other colonies this Empire has, etc.

  - Gather Operative Intelligence

    Find out what spies are on this planet, where they are from, what they are doing, etc.

  - Hack Network 19

    Attempts to besmirch the good name of the empire controlling this planet, and deprive them of a small amount of happiness.

  - Sabotage Probes

    Destroy probes controlled by this empire.

  - Rescue Comrades

    Break spies out of prison.

  - Sabotage Resources

    Destroy ships being built, docked, en route to mining platforms, etc.

  - Appropriate Resources

    Steal empty ships, ships full of resources, ships full of trade goods, etc.

  - Assassinate Operatives

    Kill spies.

  - Sabotage Infrastructure

    Destroy buildings.

  - Sabotage Defenses

    Destroy buildings that are used in defense.

  - Sabotage BHG

    Prevent enemy planet from using Black Hole Generator.

  - Incite Mutiny

    Turn spies. If successful they come work for you.

  - Abduct Operatives

    Kidnap a spy and bring him back home.

  - Appropriate Technology

    Steal plans for buildings that this empire has built, or has in inventory.

  - Incite Rebellion

    Obliterate the happiness of a planet. If done long enough, it can shut down a planet.

  - Incite Insurrection

    Steal a planet.

  **NOTE:** You can do bad things to allies using these assignments.

- noempty

  For `Security Sweep`s, a true value here indicates that you do not want
  an email when there are no spies found. Emails when spies are found, or
  when the mission fails will still be posted.

```

```
