var restify = require('restify');
var builder = require('botbuilder');

// Setup Restify Server
var server = restify.createServer();
server.listen(3978, function () {
    console.log('%s listening to %s', server.name, server.url);
});

// create bot
var connector = new builder.ChatConnector({
    appId: null,
    appPassword: null
});
var bot = new builder.UniversalBot(connector);

//handle bot framework message
server.post('/api/messages', connector.listen());

// bot.dialog('/', function (session) {
//     session.send('Hello world!');
// })

 

bot.dialog('/', [
    function (session) {
        builder.Prompts.text(session, 'What is your name?');
    },
    function (session, result) {
        var name = result.response;
        session.send('Hello %s!', name);
    }
]);