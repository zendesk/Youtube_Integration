# Youtube_Integration

This repository contains the source code for the Zendesk AnyChannel: Youtube Integration as well as the Zendesk App Market Application. The service acts as a courier of data between Zendesk and the Youtube Data API V3. 

## Interface

#### Admin
The admin interface is where the Zendesk user is able to provide the name of the Youtube Channel and Google Account authentication.

![alt text](https://www.dropbox.com/s/drllars5va7kou8/admin.png?raw=1 'admin')

When the user is being authenticated via Google oAuth, the users credentials are stored as encrypted cookies inside the browser. Upon the initial authentication, the user is issued a refresh token that is exchanged for an access token. The access token gives the integration the ability to read/write to the authenticated Youtube Channel. 

_Note: If a user has been previously authenticated via the admin interface, then the user will have to revoke that access privilege by using this [this](https://security.google.com/settings/security/permissions) link. This is because Google only issues a refresh token upon the first request for authentication._ 

---

#### Pull
The pull endpoint is the main point of contact for the AnyChannel poll. YI (Youtube Integration) will respond with an array of videos and comments formatted as an AnyChannel external resource. These resources will be filtered to only include the new reviews with a `last_pull_time` greater than the value stored in the provided state.
#####  Params
`:metadata` - `String`  Required. JSON string that must include credentials for an authenticated account.

`:state` - `String` Required. Must contain the timestamp of the most recent pull time.

---

#### Channelback
The channelback endpoint receives the external id associated with a comment on Youtube along with the message intended to reply to said comment.

##### Params
`:metadata` - `String`  Required. Provided during the /pull call.

`:state` - `String` Required. Must contain the timestamp of the most recent pull time.

---

#### Clickthrough
The clickthrough endpoint receives a GET request with the external ID of the review they'd like to load.

##### Params
`:external_id` - `String` Required. Provided during the /pull call.


## Setup
#### Setting up your developer environment
1. Clone the repo: `git clone https://github.com/zendesk/Youtube_Integration.git`

2. Run `bundle install` to install the required gems from the Gemfile

3. Start your local server: `bundle exec rackup`

4. Visit your Google Developer Console and add a project. Download the `client_secret.json`

5. Set your environment variables inside `.env`. See `example.env` for an example.

6. Add your redirect url to Google Project's list of authorized redirect urls. _Note: You may want to use ngrok to redirect a specific URL to point to your localhost_

7. Update `manifest.json`

* Documentation for various endpoints can be found in the corresponding controllers

#### Using the app in Zendesk Console
_Note: For this section we will be working with the `app_source` directory_
1. Update your `manifest.json` & `requirement.json` inside the `app_source` directory.

2. Run `zat package` followed by `zat validate`.

3. Navigate to your Zendesk Console and click on settings. On the left sidebar, select manage and upload a private app. Select the `.zip` file from the `tmp` folder inside your `app_source` directory.

4. You can now add an account by selecting `Channels Integration` on the left sidebar and selecting the Youtube Integration. 
