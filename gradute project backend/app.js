var express = require('express');
var app = express();
const path = require('path');

var admin = require('firebase-admin');
var serviceAccount = require('./firebase-service-account.json'); 

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

app.set('view engine', 'pug');

const authentication = require("./middlware/logger.authonitication");
const userRoute = require("./Modules/users/Route/Users.route.api");
app.use('/Uploade', express.static(path.join(__dirname, 'public/Uploade')));


app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/', userRoute);

module.exports = app;
