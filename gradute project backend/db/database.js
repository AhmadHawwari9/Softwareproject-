// db/index.js
const mysql = require('mysql');

const db = mysql.createConnection({
  host: 'localhost',     // Database host
  user: 'root',  // Database username
  password: '', // Database password
  database: 'graduteproject' // Database name
});

// Connect to MySQL database
db.connect((err) => {
  if (err) {
    console.error('Database connection failed: ' + err.stack);
    return;
  }
  console.log('Connected to MySQL as ID ' + db.threadId);
});

module.exports = db;
