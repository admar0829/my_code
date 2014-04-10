var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var BasicStrategy = require('passport-http').BasicStrategy;
var BearerStrategy = require('passport-http-bearer').Strategy;
var db = require('./db');

passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  db.users.find(id, function (err, user) {
    done(err, user);
  });
});

// for resource owner password credential grant type, clientId/clientSecret (client password)
// for client credential grant type, clientId/clientSecret (client password)
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
        if(token.userID != null) {
            db.users.find(token.userID, function(err, user) {
                if (err) { return done(err); }
                if (!user) { return done(null, false); }
                // to keep this example simple, restricted scopes are not implemented,
                // and this is just for illustrative purposes
                var info = { scope: '*' }
                done(null, user, info);
            });
        } else {
			db.clients.findByClientId(token.clientID, function(err, client) {
				if (err) {
					return done(err);
				}
				if (!client) {
					return done(null, false);
				}
				var info = { scope: '*' }
				done(null, client, info);
			});
		}
	});
}));