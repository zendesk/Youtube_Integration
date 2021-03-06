![repo-checks](https://github.com/zendesk/Youtube_Integration/workflows/repo-checks/badge.svg)
# Youtube Integration <img src="https://www.dropbox.com/s/uz4urq2i9kzdw86/small-logo.png?raw=1" width="35px">

This repository contains the source code for the Zendesk AnyChannel: Youtube Integration as well as the Zendesk App Market Application. The service acts as a courier of data between Zendesk and the Youtube Data API V3. 

## Key Features
__Channelback Support__: Automatically generates a reply in Youtube with the message contents as specified in Zendesk Console. 

__Clickthrough Support__: Clicking on the clickthrough link will take you to the Youtube site where the comment was initially created and highlights the comment.

__Ticket Sidebar UI__: Sidebar appears on Youtube Integration Tickets and displays the video that is associated with that ticket.
<img src="https://www.dropbox.com/s/qzwbsqixkdbuvjh/sidebar.png?raw=1">

## Installation
#### Setting up your developer environment
_It is recommended to use `bundler` to install dependencies. If you don't have `bundler`, you can download it by running `gem install bundler`._
1. Clone the repo: `git clone https://github.com/zendesk/Youtube_Integration.git`. `cd Youtube_Integration` and create an empty folder named `views` in the root.

2. Run `bundle install` to install the required gems from the Gemfile

3. Start your local server: `bundle exec rackup` and take note of the port number.

4. Download [ngrok](https://ngrok.com/download) and follow the instructions to install. After installation, navigate to where you saved `ngrok` and run `ngrok http <port number as reported by the previous step>`. Pay attention to the forwarding line that utilizes a `https` link. `Ex: Forwarding https://98a84992.ngrok.io -> localhost:9292 `

5. Visit your [Google Developer Console](https://console.developers.google.com/apis/credentials) and add a project. Afterwards, click on the `Credentials` tab in the sidebar and switch to the `OAuth consent screen.` Add a product name and save it. Next, create your `OAuth Client Id` credentials and fill in the blanks. The authorized redirect url will be your https `ngrok` url (`https://98a84992.ngrok.io`) and the authorized javascript origins will be the same url but with a `/youtube_auth` at the end (`https://98a84992.ngrok.io/youtube_auth`) . After creating your credentials, click on the newly created credential and at the top hit `Download JSON` into the root directory of `Youtube_Integration`.

6. Create a file named `.env` and copy+paste the content from `.env.example` into `.env`. Set the value of `CLIENT_SECRET = ''`. Next, put the contents of the the `client_secret` file you downloaded from your Developer Console in between the quotes. See `.env.example` for an example.

7. Update `AUTH_REDIRECT_URL` to the your redirect url you specified in your Google Developer Console (`https://98a84992.ngrok.io/youtube_auth`)

7. Update `manifest.json` and `app_source/requirements.json` with your own local or ngrok url endpoints. `EX: "event_callback_url": "https://98a84992.ngrok.io/event_callback"` _Note:_ Also feel free to update `app_source/manifest.json` but is not required.

_Note:_ If you only want to run the service locally, you can remove all references to Airbrake in `.env` and `app.rb` if you'd like.

* Documentation for various endpoints can be found in the corresponding controllers 

#### Hosting on Heroku (OPTIONAL)
1. Create a new project on Heroku

2. Set up your ENV. variables similar to your `.env` file. _Note:_ Be careful to not include quotes as Heroku will automatically stringify the values you give it.

3. Set up a github repo and connect it to your Heroku app.

4. Deploy from your `master` branch to Heroku and now the service will automatically be available.

5. Update your `manifest.json`, `app_source/requirements.json`, `.env` to now point to your heroku url endpoints

6. Add your Heroku urls to your [Google Developer Console](https://console.developers.google.com/apis/credentials).

#### Setting up Airbrakes on Heroku (OPTIONAL)
1. Add the Airbrake Error Monitoring Add On for free on Heroku.

2. Find your Airbrake Id & Key (easiest way is to just click on the Add-On and in the `Overview` section of Heroku. This will redirect you to the Add-On site and choose `Sinatra` for project type.)

3. Set your ENV variables on Heroku with the Airbrake Id & Keys. Ex:`AIRBRAKE_Id=111111`

#### Using the app in Zendesk Support
_Note: Check that your `manifest.json`, `app_source/requirements.json`, `.env` files point to the right endpoints (heroku/ngrok)
1. `cd app_source`

2. Run `gem update zendesk_apps_tools`

3. Run `zat package` followed by `zat validate`. This will create a `.zip` file in `app_source/tmp`

4. Navigate to your Zendesk site and click on settings. On the left sidebar, select manage and upload a private app. Select the `.zip` file from the `tmp` folder inside your `app_source` directory. 

5. After uplaoding & installing, you can now add an account by selecting `Channels Integration` on the left sidebar and selecting the Youtube Integration.

## Testing
To run the test files, run `bundle exec rspec` in the app source.

## Interface

#### Admin
The admin interface is where the Zendesk user is able to provide the name of the Youtube Channel and Google Account authentication.

![alt text](https://www.dropbox.com/s/drllars5va7kou8/admin.png?raw=1 'admin')

When the user is being authenticated via Google oAuth, the users credentials are stored as encrypted cookies inside the browser. Upon the initial authentication, the user is issued a refresh token that is exchanged for an access token. The access token gives the integration the ability to read/write to the authenticated Youtube Channel. 

_Note: If a user has been previously authenticated via the admin interface, then the user will have to revoke that access privilege by using this [this](https://security.google.com/settings/security/permissions) link. This is because Google only issues a refresh token upon the first request for authentication._ 

---

#### Pull
The pull endpoint is the main point of contact for the AnyChannel poll. YI (Youtube Integration) will respond with an array of videos and comments formatted as an AnyChannel external resource. These resources will be filtered to only include the new reviews with a `last_pull_time` greater than the value stored in the provided state.

_Pull logic_: Zendesk pings the service every 2 minutes and expects a response within a minute timeframe per pull request. Youtube Integration utilizes a batch fetch method that will grab 5 videos and up to 200 comments per video per batch. As long as their is still time left before Zendesk expects a respone, YI will continue to try to make more batch fetches.

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

## Contributing
Branch off of master and open a PR. If all the test cases pass and you receive a +1 from an admin you will have the option to merge your changes.
