const db = require('../../../db/database');
const bcrypt = require('bcrypt');

const login = (email, password) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM users WHERE Email = ?';
        
        db.query(query, [email], (error, results) => {
            if (error) {
                console.error('Error querying database: ', error);
                return reject({ error: 'Database error' });
            }

            if (results.length > 0) {
                const user = results[0];
                // Compare the provided password with the hashed password in the database
                bcrypt.compare(password, user.Password, (err, isMatch) => {
                    if (err) {
                        console.log(err);
                        return reject({ error: 'Error checking password' });
                    }

                    if (isMatch) {
                        // Passwords match, login successful
                        resolve({ message: 'Login successful', userId: user.id });
                    } else {
                        // Passwords do not match, but email exists
                        reject({ error: 'Incorrect password' });
                    }
                });
            } else {
                // No user found with that email
                reject({ error: 'Email does not exist' });
            }
        });
    });
};

module.exports = {
    login
};
