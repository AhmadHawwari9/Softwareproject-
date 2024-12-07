const db = require('../../../db/database');

const getAllUsers = () => {
  return new Promise((resolve, reject) => {
    const query = `
      SELECT 
        users.User_id, 
        users.First_name, 
        users.Last_name, 
        users.Email, 
        users.Type_oftheuser, 
        users.Bio,
        filemannager.path AS image_path
      FROM users
      LEFT JOIN filemannager ON users.image_id = filemannager.file_id
    `;

    db.query(query, (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
};

const getUserByIdFromDb = (id) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          users.User_id, 
          users.First_name, 
          users.Last_name, 
          users.Email, 
          users.Type_oftheuser, 
          users.Bio,
          filemannager.path AS image_path
        FROM users
        LEFT JOIN filemannager ON users.image_id = filemannager.file_id
        WHERE users.User_id = ?
      `;
  
      db.query(query, [id], (err, results) => {
        if (err) {
          return reject(err);
        }
        if (results.length === 0) {
          return resolve(null); // User not found
        }
        resolve(results[0]); // Return the user
      });
    });
  };

module.exports = {
  getAllUsers,
  getUserByIdFromDb
};
