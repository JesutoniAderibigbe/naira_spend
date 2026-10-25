---
name: naira-definition-of-done
description: Checklist to run before reporting any task in this repo as done. Use at the end of every coding task and whenever asked to verify.
---
1. Analyze and fix every issue; format.
2. Run flutter test. New logic has unit tests (include zero, month
   boundaries and exactly-at-limit cases); new widgets have widget tests.
3. If the app is running: connect with Marionette, hot reload, walk the
   changed flow like a user, take a screenshot, check get_logs.
4. If the screen has a Figma frame, compare the screenshot with it.
5. Check the diff against AGENTS.md (kobo ints, one formatter, layers,
   Keys, no secrets).
6. Report: files changed, test results, runtime check, anything unsure.