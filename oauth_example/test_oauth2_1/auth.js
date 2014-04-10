var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var BasicStrategy = require('passport-http').BasicStrategy;
var BearerStrategy = require('passport-http-bearer').Strategy;
var db = require('./db');


passport.use(new LocalStrategy({passReqToCallback: true}, function(req, username, password, done) {
	console.log(req.body);
	db.clients.findByClientId(username, function(err, client) {
		if (err) {
			return done(err);
		}
		if (!client) {
			return done(null, false);
		}
		if (client.clientSecret != password) {
			return done(null, false);
		}
		return done(null, client);
	});
}));


passport.use(new BasicStrategy(function(username, password, done) {
	db.clients.findByClientId(username, function(err, client) {
		if (err) {
			return done(err);
		}
		if (!client) {
			return done(null, false);
		}
		if (client.clientSecret != password) {
			return done(null, false);
		}
		return done(null, client);
	});
}));

passport.use(new BearerStrategy(function(accessToken, done) {
	db.accessTokens.find(accessToken, function(err, token) {
		if (err) {
			return done(err);
		}
		if (!token) {
			return done(null, false);
		}
		
		db.clients.findByClientId(token.clientID, function(err, client) {
			if (err) {
				return done(err);
			}
			if (!client) {
				return done(null, false);
			}
			done(null, client);
		});
	});
}));