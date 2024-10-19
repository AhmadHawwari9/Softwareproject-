var  express = require('express');
var app=express();
app.set('view engin','pug');
const authonitication=require("./middlware/logger.authonitication")

const userRoute = require("./Modules/users/Route/Users.route.api")

app.use(express.json());
app.use(express.urlencoded({extended:false}));


app.use('/',userRoute);

module.exports = app;

