var NameForm = React.createClass({
	onFormSubmit: function (e) {
		e.preventDefault();
		// SUBMIT ACCOUNT INFORMATION HERE

	},
	render: function () {	
		return (
			<div class="wrapper">
				<h1 class="title">Youtube Integration</h1>
				<form onSubmit={this.onFormSubmit}>
						<input type="text" placeholder="Account Name"/>
						<input type="text" placeholder='Channel ID'/>
						<p> Note: You can find your Youtube Channel ID <a href="http://www.youtube.com/account_advanced" target="_blank">here</a></p>
						<a className="button" href="/youtube_auth">Next</a>
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
