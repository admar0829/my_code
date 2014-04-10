var clients = [
    { id: '1', name: 'client_1', clientId: 'client_1', clientSecret: 'Citibank2014' },
    { id: '2', name: 'client_1', clientId: 'client_2', clientSecret: 'Citibank2014' }
];


exports.find = function(id, done) {
  for (var i = 0, len = clients.length; i < len; i++) {
    var client = clients[i];
    if (client.id === id) {
      return done(null, client);
    }
  }
  return done(null, null);
};

exports.findByClientId = function(clientId, done) {
  for (var i = 0, len = clients.length; i < len; i++) {
    var client = clients[i];
    if (client.clientId === clientId) {
      return done(null, client);
    }
  }
  return done(null, null);
};
