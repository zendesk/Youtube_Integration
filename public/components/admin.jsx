var NameForm = React.createClass({
	onFormSubmit: function (e) {
		e.preventDefault();
		
		const channel_name = document.getElementById('channel_name').value;
		const channel_id = document.getElementById('channel_id').value;
		const return_url = document.getElementById('admin').getAttribute("return_url");
		const subdomain = document.getElementById('admin').getAttribute('subdomain');
		const locale = document.getElementById('admin').getAttribute('locale');
		const timeStamp = new Date(Date.now()).toISOString();

		if (document.getElementById('button').innerHTML == "I have authenticated my Google account.") {
			window.location.assign('/auth_display')
		} else {
			if (channel_name.length < 1 || channel_id.length < 1) { // NOT A VALID CHANNEL NAME OR ID
				document.getElementById('err').style.display = "block";
			} else if (channel_name.length > 255) { // length too long
				document.getElementById('too_long').style.display = "block";
			} else {
				document.getElementById('err').style.display = "none";
				document.getElementById('too_long').style.display = "none";
				window.open("/youtube_auth?channel_id="+ channel_id +"&channel_name="+ channel_name +"&return_url="+ return_url + "&timestamp="+ timeStamp + "&subdomainin="+ subdomain + "&locale=" + locale);
				document.getElementById('button').innerHTML = "I have authenticated my Google account."
			}
		}
	},
	render: function () {	
		return (
			<div>
				<h1 className="title">Youtube Integration</h1>
				<form>
						<input type="text" placeholder="Account Name:" id="channel_name"/>
						<br />
						<input type="text" placeholder='Channel ID:' id="channel_id"/>
						<p> Note: You can find your Youtube Channel ID <a href="http://www.youtube.com/account_advanced" target="_blank">here</a></p>
						<a id="button" className="button" onClick={this.onFormSubmit}>Next</a>
						<div id="err" style={{display:'none'}}> 
							<br />
							<p style={{color:'red'}}>Please ensure that you have entered a valid channel id and name.</p>
						</div>
						<div id="too_long" style={{display:'none'}}>
							<p style={{color:'red'}}>Account name must be less than 255 characters.</p>
						</div>
				</form>
			</div>
		);
	}
});

var Admin = React.createClass({	
	render: function () {
		return (
			<div>
				<NameForm />
			</div>
		);
	}
});

ReactDOM.render(
	<Admin />, document.getElementById('admin')
);
