var users = [
    { id: '1', username: 'Kevin', password: 'password', name: 'Yuwei Xia' },
    { id: '2', username: 'Chris', password: 'password', name: 'Christropher Lawless' }
];


exports.find = function(id, done) {
  for (var i = 0, len = users.length; i < len; i++) {
    var user = users[i];
    if (user.id === id) {
      return done(null, user);
    }
  }
  return done(null, null);
};

exports.findByUsername = function(username, done) {
  for (var i = 0, len = users.length; i < len; i++) {
    var user = users[i];
    if (user.username === username) {
      return done(null, user);
    }
  }
  return done(null, null);
};