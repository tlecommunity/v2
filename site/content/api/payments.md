---
date: 2022-10-31
type: 'page'
---

# Payments

The payments system allows users to purchase essentia. There's not much for an app developer to do here except to hand off to the payment system. Usually this involves opening a window for them.

**NOTE:** This API is **not** JSON-RPC based.

To initiate the payments process you simply need to open the following url:

    https://servername.lacunaexpanse.com/pay?session_id=xxxxxxxxxxxxxxxx

The payment system will handle the rest.

**NOTE:** The parameters in the above URL can be passed via GET or POST, it doesn't matter which.
