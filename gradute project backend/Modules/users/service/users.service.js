const db = require('../../../db/database');
const bcrypt = require('bcrypt');

const createUser = (first_name, last_name, email, age, password, typeofuser) => {
    return new Promise((resolve, reject) => {
        // Correct SQL query
        const query = 'INSERT INTO users (First_name, Last_name, Email, Age, Password, Type_oftheuser) VALUES (?, ?, ?, ?, ?, ?)';

        // Salt rounds for bcrypt
        const saltRounds = 10;

        // Hash the password before saving it to the database
        bcrypt.hash(password, saltRounds, (err, hash) => {
            if (err) {
                console.error('Error hashing password: ', err);
                return reject({ error: 'Error hashing password' });
            }

            // Replace plain-text password with the hashed password
            const values = [first_name, last_name, email, age, hash, typeofuser];

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
