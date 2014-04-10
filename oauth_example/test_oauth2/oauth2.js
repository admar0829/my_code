var oauth2orize = require('oauth2orize');
var passport = require('passport');
var db = require('./db');
var utils = require('./utils');

var server = oauth2orize.createServer();

server.serializeClient(function(client, done) {
  return done(null, client.id);
});

server.deserializeClient(function(id, done) {
  db.clients.find(id, function(err, client) {
    if (err) { return done(err); }
    return done(null, client);
  });
});

server.exchange(oauth2orize.exchange.clientCredentials(function(client, scope, done) {
	db.clients.findByClientId(client.clientId, function(err, localClient) {
		if (err) {
			return done(err);
		}
		if (localClient === null) {
			return done(null, false);
		}
		if (localClient.clientSecret !== client.clientSecret) {
			return done(null, false);
		}
		var token = utils.uid(256);
		db.accessTokens.save(token, null, client.clientId, function(err) {
			if (err) {
				return done(err);
			}
			done(null, token);
		});
	});
}));


exports.token = [
passport.authenticate('basic', { session: false}),
server.token(),
server.errorHandler()
]


exports.info = [
    passport.authenticate('bearer', { session: false }),
    function(req, res) {
        res.json({ client_id: req.user.clientId, name: req.user.name, message: "Hello world!" })
    }
]