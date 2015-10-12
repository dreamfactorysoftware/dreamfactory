<html>
	<head>
		<title>DreamFactory</title>
		
		<link href='//fonts.googleapis.com/css?family=Lato:100' rel='stylesheet' type='text/css'>

		<style>
			body {
				margin: 0;
				padding: 0;
				width: 100%;
				height: 100%;
				color: #B0BEC5;
				display: table;
				font-weight: 100;
				font-family: 'Lato';
                background-color: #353535;
			}

			.container {
				text-align: center;
				display: table-cell;
				vertical-align: middle;
			}

			.content {
				text-align: center;
				display: inline-block;
			}

			.title {
				font-size: 96px;
				margin-bottom: 40px;
			}

			.quote {
				font-size: 24px;
			}
		</style>
	</head>
	<body>
		<div class="container">
			<div class="content">
				<div class="title">DreamFactory 2.0</div>
				<div class="quote">{{ Inspiring::quote() }}</div>
                <div>
                    <br>
                    <input type="button" value="Launchpad" onclick="javascript: location.href='launchpad'"/>
                    <input type="button" value="Admin Panel" onclick="javascript: location.href='admin'"/>
                </div>
			</div>
		</div>
	</body>
</html>
