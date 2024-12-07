const db = require('../../../db/database');

const getUserType = (userId) => {
    const sql = 'SELECT Type_oftheuser FROM users WHERE User_id = ?';

    return new Promise((resolve, reject) => {
        db.query(sql, [userId], (err, results) => {
            if (err) {
                console.error("Error fetching user type:", err);
                return reject(err);
            }

            if (results.length > 0) {
                resolve(results[0].Type_oftheuser); // Return the Type_oftheuser value
            } else {
                resolve(null); // User not found, return null
            }
        });
    });
};


module.exports = {
    getUserType
};
