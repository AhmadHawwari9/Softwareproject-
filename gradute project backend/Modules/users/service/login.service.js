const db = require('../../../db/database');
const bcrypt = require('bcrypt');

const login = async (email, password) => {
    return new Promise((resolve, reject) => {
        // Query to get user by email
        db.query("SELECT User_id, Email, Password FROM users WHERE Email = ?", [email], (err, results) => {
            if (err) {
                return reject({ error: 'Database query error' });
            }
            if (results.length === 0) {
                return reject({ error: 'User not found' });
            }

            const user = results[0];
            // Compare the provided password with the hashed password in the database
            bcrypt.compare(password, user.Password, (err, isMatch) => {
                if (err) {
                    return reject({ error: 'Error checking password' });
                }

                if (isMatch) {
                    // Return User_id and Email
                    resolve({ userId: user.User_id, email: user.Email });
                } else {
                    reject({ error: 'Incorrect password' });
                }
            });
        });
    });
};

module.exports = {
    login
};
