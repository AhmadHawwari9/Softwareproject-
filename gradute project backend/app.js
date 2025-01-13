var express = require('express');
var app = express();
const path = require('path');
const cors = require('cors');

// Firebase Admin SDK initialization
var admin = require('firebase-admin');
var serviceAccount = require('./firebase-service-account.json'); 

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

// Enable CORS for all origins and methods
app.use(cors({
    origin: '*', // Allow all origins
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Allowed methods
    allowedHeaders: ['Content-Type', 'Authorization', 'token'], // Explicitly allow 'token'
    credentials: true, // Allow cookies if necessary
}));

// Serve the Firebase service worker file explicitly
app.use('/firebase-messaging-sw.js', express.static(path.join(__dirname, 'web/firebase-messaging-sw.js')));

// Set view engine to Pug
app.set('view engine', 'pug');

// Middleware imports
const authentication = require("./middlware/logger.authonitication");
const userRoute = require("./Modules/users/Route/Users.route.api");

// Serve static files for uploaded content
app.use('/Uploade', cors(), express.static(path.join(__dirname, 'public/Uploade')));

// Middleware for parsing JSON and URL-encoded data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/', userRoute);

// Catch-all route for handling SPA (if needed)
app.get('*', (req, res) => {
    res.status(404).send('Page not found'); // Adjust as per your app's requirements
});

// Export the app module
module.exports = app;
