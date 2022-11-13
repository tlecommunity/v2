---
date: 2022-10-31
type: 'page'
---

# Captcha Methods

The following methods are available from `/captcha`.

## fetch

Retrieves a captcha that is required in order to call the `solve` method.
Display the resulting captcha in your creation form and then call `solve` with the user's response.

Accepts either fixed arguments or a hash of named parameters

    ( session_id)
    ( parameter_hash )

### session_id (required)

A session ID

### RESPONSE

```json
{
  "guid": "id-goes-here",
  "url": "'https://extras.lacunaexpanse.com.s3.amazonaws.com/captcha/id/id-goes-here.png"
}
```

## solve

Validates the user's solution against the known solution for the given guid.
If the solution validates, the captcha will be valid for thirty minutes (an expiration timestamp is set
in the session) and it returns a value of 1.

**NOTE:** If either `captcha_guid` or `captcha_solution` don't match what the server is expecting it
will throw a 1014 error, and the data portion of the error message will contain new captcha information.
You must use this. A captcha cannot be used more than once.

Throws 1014.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, guid, solution)
    ( parameter_hash )

### session_id (required)

A session ID

### guid (required)

This must match the `guid` field returned by the `fetch` method.

### solution (required)

This is the text typed in by the user as the solution of the captcha.

```

```
