# README

This is a small app that maintains a queue for the staging environment. It's controlled by Slack slash commands:

```
/lock - locks the staging environment, or hop on the queue if it's already taken
/unlock - unlocks
/queue - shows the current queue
```

It's hosted on Heroku and maintains the queue in Redis. There is no database dependency.

### Setup

Clone this repo, make sure you have the correct version of ruby installed, and `bundle install`. For local development, I:
* Used ngrok to generate a public URL that exposes your local server
* Pointed the slash commands to the public URL that ngrok generated (https://api.slack.com/apps/)

### Deployment

Currently this is deployed with `git push heroku master`

### Tests

Run tests with `rspec`
