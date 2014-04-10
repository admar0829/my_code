var express = require('express');
var passport = require('passport');
var util = require('util');
var oauth2 = require('./oauth2');

var app = express();
app.use(express.cookieParser());
app.use(express.bodyParser());

app.use(passport.initialize());
app.use(passport.session());
app.use(app.router);

require('./auth');

app.post('/oauth/token', oauth2.token);


//client credential grant type, to get client info
app.get('/api/clientinfo', oauth2.clientInfo);

//resource owner password credential grant type, to get user info
app.get('/api/userinfo', oauth2.userInfo);

app.listen(3000);
console.log("Now listening port 3000.........");