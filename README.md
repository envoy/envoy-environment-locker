# README

This is a small app that maintains a queue for the staging environment. It's controlled by Slack slash commands:

```
/lock - locks the staging environment, or hop on the queue if it's already taken
/unlock - unlocks, or hop off the queue
/queue - shows the current queue
```

The queue is maintained in Redis, and there is no database dependency.

### Why did we make this?

Envoy has a staging environment that developers can use to test code changes before they're deployed to production. Only one developer should be making changes to the staging environment at a time, so an informal system developed wherein a developer would post in the #staging-checkout Slack channel to see if it was available to use. This ended up causing several problems:

* A non-answer in #staging-checkout didn't necessarily mean staging was available - it could have been that the person using it was busy and didn't see the Slack message.
* Sometimes many developers would request to use the staging environment around the same time, resulting in confusion and time spent discussing "who gets it next".

We created this tool to maintain a simple queue and give an easy interface for viewing, adding to, and removing from the queue. It's saved us time and decreased confusion.

### Setup

Clone this repo, make sure you have the correct version of ruby installed, and `bundle install`.
* First you'll have to add a new app to your Slack instance. You can get started [here](https://api.slack.com/apps) (click "Create New App").
* On the newly created Slack App, add features for Incoming Webhooks and Slash Commands.
* Under Slash Commands, create three new commands: `/lock`, `/unlock`, and `/queue`. This is how users will interact with the application and manage their position on the environment queue. The request URL you specifiy will depend on where you host this application, just put the application URL in here.
* Whichever channel you want the app to post in, set up an Incoming Webhook to expose a URL for that channel. You'll need to set the webhook URL that's generated as the `SLACK_WEBHOOK_URL` environment variable.
* Another environment variable that's necessary is `SLACK_SECRET_TOKEN`, which for now is the verification token that Slack generates when you create the Slack App.
* You can change the display settings for the App name, icon, etc. here in Slack.

### Local Development
* Use ngrok or similar tool to generate a public URL that exposes your local server.
* Use this URL in the Slash Commands Slack configuration (perhaps under your own `/test` command) so that `/test` will hit your local server with a representative payload you can work with.

### Tests

Run tests with `rspec`

### Future Improvements

* More comprehensive error handling
* Upgrade `SLACK_SECRET_TOKEN` to use more secure secret strategy.
* Allow the app to send DMs to the client, when requested, so that you could view the queue without pinging the current members.

### MIT License

Copyright 2019 Envoy Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
