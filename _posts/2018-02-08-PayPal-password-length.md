---
title: PayPal Passwords silently truncated after 20 characters
layout: default
comments: true
tags:
 - PayPal
 - Passwords
 - Password Manager
 - Security
---

It seems that the PayPal registration form and the form to change the PayPal password will silently truncate long passwords to a maximum length of 20 characters. However, the PayPal login form will allow you to enter passwords with no length limitation. At login, the full length of the password provided is used to check if it matches the password which was previously truncated to a maximum length of 20 characters.

Beware: If you use password managers, such as for example [KeePass](https://en.wikipedia.org/wiki/KeePass), you may find yourself in a situation where you've generated and (think that you've) set a PayPal password with more than 20 characters length, but you're unable to log in when trying to use this very password. PayPal has silently truncated your password, so you must provide the truncated password in the log in form as well.

NB: PayPal customer support has assured me that PayPal is busy with important things and has put this issue "at the bottom of their list". Well, let's hope other people are not also wasting their time on this until PayPal finds the time to pick this up.
