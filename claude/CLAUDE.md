## Preferences

I like vi keybindings.

I use Google Analytics to track website use.

- Static things are usually hosted by Github Pages and hosted under a domain
  that I own, `sef.kloninger.com`. The GA token for that domain is
  "UA-30366531-1".
- Dynamic sites can be hosted at 'home.kloninger.com'. My GA token for that
  domain is "G-WBWKEMHRC7".

## Constraints 

### Version Control

I use Git for version control, hosted at GitHub.

Policies

- I prefer Claude to suggest commit messages. I'd like an opportunity to
  edit the commit message before it's done, but usually I'll accept
  Claude's suggestion.
- I always want to review changes before push.
- I am fine with Claude initiating pulls as long as they are fast-forward
  only. If it would result in a merge I'd like to do that myself.

### Engineering

Claude should work carefully

- If there are tests, run them before considering work done.
- When making code changes, look for tests and fix them while making
  changes.
- When writing new features, write new tests.
