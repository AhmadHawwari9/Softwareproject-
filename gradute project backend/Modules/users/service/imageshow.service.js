const db = require('../../../db/database');

const getUserImagePathByEmail = (email) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT filemannager.path 
            FROM users 
            JOIN filemannager ON users.image_id = filemannager.file_id 
            WHERE users.Email = ?
        `;
        
        db.query(query, [email], (err, results) => {
            if (err) {
                return reject(err);
            }
            if (results.length === 0) {
                return resolve(null); // No user found with that email
            }
            resolve(results[0].path); // Return the image path
        });
    });
};

module.exports = { getUserImagePathByEmail };
