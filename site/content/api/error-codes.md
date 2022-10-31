---
date: 2022-10-31
type: 'page'
---

# Error Codes

The following game error codes may be thrown by the Lacuna game server.

## 1000 Name not available.

Perhaps it already exists, or it's blank, or it contains unusable characters.

## 1001 Invalid password.

Passwords cannot be empty and they must be at least 6 characters long.

## 1002 Object does not exist.

The object you've requested by id doesn't exist.

## 1003 Too much information.

You've requested too much information from the server at once.

## 1004 Password incorrect.

The user mistyped the password, or doesn't know it.

## 1005 Contains invalid characters.

Thrown when a text field contains invalid characters.

## 1006 Session expired.

A basic authorization denied error, because the session you're trying to connect with doesn't exist or has expired.

## 1007 Overspend.

You have tried to spend more resources than you have.

## 1008 Underspend.

You need to spend more resources than you have spent.

## 1009 Invalid range.

The items in the range don't fit the rules for the range. For example, habitable stellar orbits must be consecutive, so a range of 1,3,5 would trigger this error.

## 1010 Insufficient privileges.

The authenticated empire doesn't have the privileges to complete the requested action.

## 1011 Not enough resources in storage.

The empire/planet/station doesn't have enough resources in storage to complete the requested action. Build more wealth to fix the problem.

## 1012 Not enough resources in production.

The empire/planet/station isn't producing enough resources to keep up with the demands of this action. If the action were allowed to complete it would bankrupt the empire.

## 1013 Missing prerequisites.

The empire/planet/station hasn't completed building the prerequisite buildings in order to build something new.

## 1014 Captcha not valid.

A captcha was required for this request and it was not valid. The data portion will contain new captcha information to try again.

## 1015 Restricted for sitter logins.

The function you were attempting to access is not valid for sitter accounts.

## 1016 Needs to solve a captcha.

The old captcha has expired. A new captcha is needed.

## 1017 Pending Parliamentary Vote

The action you tried to perform has been put on hold pending a parliamentary vote.

## 1018 Already Voted

You've already voted on this proposition.

## 1100 Empire not founded.

You're trying to log in to an empire that is part way through the creation process. The data portion will tell you the empire id so that they can update the species and found the empire.

## 1101 Empire not founded, and you tried to create it, but had the wrong password.

This message will only occur if a user tries to create an empire with a name that already exists, but has not yet been founded, and the user doesn't enter the same password as they did when they first created the empire.

## 1200 Game Over.

This game has come to an end. The data section of this exception will contain a URI to a web page that shows the final stats.
