# README

This is a small app that maintains a queue for the any service. It's controlled by Slack slash commands:

```
/lock <service> [for X minutes/hours] - request the lock for <service> and once acquired it'll hold it for X minutes/hours.
/unlock <service> - unlocks or hop off the queue for a given service.
/queue <service> - shows the current queue for a service.
```

If the user doesn't provide any timing information for `/lock`, the lock will be requested for 30 minutes.

## How locking works

The data is mainly stored in Redis two sorted sets:

* `services:__locked__`: Holds the name of all the services that are currently locked. The `score` of each element is the timestamp of when the service should be unlocked.

* `services:{name}:queue`: Holds the users that have requested the lock on the service. The first element of the set is the current lock holder. The values are stored with `{username}:{seconds_requested}`.

Running the following Ruby code

```ruby
s = Service.new("api")
s.lock(user: "U-USERID1", seconds: 30)
s.lock(user: "U-USERID2", seconds: 60)
```

results in having the following values in Redis:

```
127.0.0.1:6379> ZRANGE services:api:queue 0 -1
1) "U-USERID1:30"
2) "U-USERID2:60"
```

## Automatic Unlocks & Warnings

Since the lock has an expiration date, we can poll the `services:__locked__` sorted set to get all the services that has their locks expired or about to expired.

* For each expired services we force an unlock by calling `#expire_lock!`.
* For services that are about to expire, we send the lock holder a warning via DM letting them know that the lock will expire soon. Users can then decide to `unlock` the service or request 15 extra minutes:

![Expiration Warning](https://cl.ly/95591169ab21/Image%2525202019-04-20%252520at%2525209.39.34%252520PM.png)

This is all done with the `AutoExpirer.expire_all!` method.

## Threaded Auto Expire

If you're running this application in Heroku **and have a single dyno**, you can set the `THREADED_AUTO_EXPIRE` environment variable as `true`.

It's very important that you only do this if you have a single instance of the application running. Otherwise services will be unlocked multiple times.

If you want to more control on when to run it, you can setup a cronjob that runs `bundle exec bin/rails runner bin/expire` and that will unlock expired locks and warn users about locks that are about to expire.


## Setup

Clone this repo, make sure you have the correct version of ruby installed, and `bundle install`.

* First you'll have to add a new app to your Slack instance. You can get started [here](https://api.slack.com/apps) (click "Create New App").
* Under **Slash Commands**, create three new commands: `/lock`, `/unlock`, and `/queue`. This is how users will interact with the application and manage their position on the environment queue. The request URL you specifiy will depend on where you host this application, just put the application URL in here.
* Enable **Interactive Components** and use `https://<yourapp-path.com>/buttons` as your Request URL.
* Add the `SLACK_API_TOKEN` and `SLACK_SECRET_TOKEN` environment varianles:
  * `SLACK_API_TOKEN`: The **bot** OAuth token for your application.
  * `SLACK_SECRET_TOKEN`: The **verification token** found in the Basic Information section of your application.
* You can change the display settings for the App in Slack.
* Under the **OAuth** section add the `chat:write:bot` scope
  ![](https://cl.ly/aafd1ccb705f/Image%2525202019-04-20%252520at%2525209.57.38%252520PM.png)

### Local Development

* Use ngrok or similar tool to generate a public URL that exposes your local server. Make sure to update the application URLs.

### Tests

Run tests with `rspec`

### Future Improvements

* Upgrade `SLACK_SECRET_TOKEN` to use more secure secret strategy.
* Allow the app to send DMs to the client, when requested, so that you could view the queue without pinging the current members.

### MIT License

Copyright 2019 Envoy Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
