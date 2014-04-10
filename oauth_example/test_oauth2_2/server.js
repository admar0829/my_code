var express = require('express');
var app = express();
var crypto = require('crypto');


app.all('*', function(req, res, next) {
  var token = req.get('Authorization').split(" ")[1];
  var keychain = "keychain";
  var decipher = crypto.createDecipher('aes-256-cbc', keychain);
  var decodedToken = decipher.update(token, 'base64', 'utf8');
  decodedToken = decodedToken + decipher.final('utf8');
  console.log('decrypted: ' + decodedToken)
  
  //var decodedToken = new Buffer(token, 'base64').toString('utf8');
  var jsonToken = JSON.parse(decodedToken);
  var host = jsonToken.host;
  var permission = jsonToken.permission;
  if ( host === "localhost:3001" && permission) {
 	 next();
  } else if (host === "localhost:3001" && !permission) {
	 res.send(401, 'unauthorised');
  }
});

app.get('/index', function(req, res) {
	res.send('Hello World!');
});

app.listen(3001);
console.log("Now listening port 3001.........");