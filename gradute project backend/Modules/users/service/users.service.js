const db = require('../../../db/database');
const bcrypt = require('bcrypt');

const createUser = (first_name, last_name, email, age, password, typeofuser,img_id) => {
    return new Promise((resolve, reject) => {
        // Correct SQL query
        const query = 'INSERT INTO users (First_name, Last_name, Email, Age, Password, Type_oftheuser,image_id) VALUES (?, ?, ?, ?, ?, ?,?)';

        // Salt rounds for bcrypt
        const saltRounds = 10;


        bcrypt.hash(password, saltRounds, (err, hash) => {
            if (err) {
                console.error('Error hashing password: ', err);
                return reject({ error: 'Error hashing password' });
            }

 
            const values = [first_name, last_name, email, age, hash, typeofuser,img_id];

            // Execute the database query
            db.query(query, values, (error, results) => {
                if (error) {
                    console.error('Error inserting data: ', error);
                    return reject({ error: 'Database error' });
                }
                resolve({ message: 'User created successfully', userId: results.insertId });
            });
        });
    });
};

module.exports = {
    createUser
};
