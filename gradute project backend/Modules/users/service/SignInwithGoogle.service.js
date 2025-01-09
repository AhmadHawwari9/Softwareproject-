const db = require('../../../db/database');

const signInWithGoogle = (email) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM users WHERE Email = ?';
        
        db.query(query, [email], (error, results) => {
            if (error) {
                console.error('Error querying database: ', error);
                return reject({ error: 'Database error' });
            }

            if (results.length > 0) {
                const user = results[0];
                // Return email and password (hashed) if email exists
                resolve({ email: user.Email, password: user.Password });
            } else {
                // No user found with that email
                reject({ error: 'Email does not exist' });
            }
        });
    });
};

module.exports = {
    signInWithGoogle
}; 