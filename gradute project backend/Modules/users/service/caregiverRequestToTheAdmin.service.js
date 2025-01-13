const db = require('../../../db/database');
const bcrypt = require('bcrypt');

const createCaregiver = (first_name, last_name, email, age, password, typeofuser, photoId, cvId) => {
    return new Promise((resolve, reject) => {
        const query = 'INSERT INTO caregiverrequesttoadmin (First_name, Last_name, Email, Age, Password, Type_oftheuser, image_id, cv_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';

        // Hash password
        bcrypt.hash(password, 10, (err, hashedPassword) => {
            if (err) {
                return reject({ error: 'Error hashing password' });
            }

            const values = [first_name, last_name, email, age, hashedPassword, typeofuser, photoId, cvId];

            db.query(query, values, (error, results) => {
                if (error) {
                    return reject({ error: 'Database error' });
                }
                resolve({ message: 'Caregiver created successfully', caregiverId: results.insertId });
            });
        });
    });
};


const getAllCaregivers = () => {
  return new Promise((resolve, reject) => {
    const query = `
    SELECT c.Request_id, c.First_name, c.Last_name, c.Email, c.Age, c.Password, c.Type_oftheuser, f.path AS cv_path
    FROM caregiverrequesttoadmin c
    JOIN filemannager f ON c.cv_id = f.file_id
    WHERE c.Type_oftheuser = 'Caregiver'
  `;

    db.query(query, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results);
      }
    });
  });
};


  const moveCaregiverToUser = (requestId) => {
    return new Promise((resolve, reject) => {
      const selectQuery = `
        SELECT c.Request_id, c.First_name, c.Last_name, c.Email, c.Age, c.Password, c.Type_oftheuser, c.image_id, c.cv_id
        FROM caregiverrequesttoadmin c
        WHERE c.Request_id = ?
      `;
      
      db.query(selectQuery, [requestId], (err, results) => {
        if (err) {
          reject(err);
        } else {
          if (results.length === 0) {
            reject(new Error('Request ID not found'));
          } else {
            const caregiver = results[0];
            
            const insertQuery = `
              INSERT INTO users (First_name, Last_name, Email, Age, Password, Type_oftheuser, image_id, cv_id)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `;
            
            db.query(insertQuery, [caregiver.First_name, caregiver.Last_name, caregiver.Email, caregiver.Age, caregiver.Password, caregiver.Type_oftheuser, caregiver.image_id, caregiver.cv_id], (err, result) => {
              if (err) {
                reject(err);
              } else {
                const deleteQuery = `
                  DELETE FROM caregiverrequesttoadmin WHERE Request_id = ?
                `;
                
                db.query(deleteQuery, [requestId], (err, deleteResult) => {
                  if (err) {
                    reject(err);
                  } else {
                    resolve({
                      message: 'Caregiver moved to users and request deleted successfully',
                      userId: result.insertId
                    });
                  }
                });
              }
            });
          }
        }
      });
    });
  };


  const deleteCaregiverRequest = (requestId) => {
    return new Promise((resolve, reject) => {
      // Query to select caregiver data
      const selectQuery = `
        SELECT c.Request_id, c.First_name, c.Last_name, c.Email, c.Age, c.Password, c.Type_oftheuser, c.image_id, c.cv_id
        FROM caregiverrequesttoadmin c
        WHERE c.Request_id = ?
      `;
      
      db.query(selectQuery, [requestId], (err, results) => {
        if (err) {
          reject(err);
        } else {
          if (results.length === 0) {
            reject(new Error('Request ID not found'));
          } else {
            // Delete the caregiver request without inserting into the users table
            const deleteQuery = `
              DELETE FROM caregiverrequesttoadmin WHERE Request_id = ?
            `;
            
            db.query(deleteQuery, [requestId], (err, deleteResult) => {
              if (err) {
                reject(err);
              } else {
                resolve({
                  message: 'Caregiver request deleted successfully'
                });
              }
            });
          }
        }
      });
    });
  };

  const getAllHospitals = () => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT c.Request_id, c.First_name, c.Last_name, c.Email, c.Age, c.Password, c.Type_oftheuser, f.path AS cv_path
        FROM caregiverrequesttoadmin c
        JOIN filemannager f ON c.cv_id = f.file_id
       
      `;
  
      db.query(query, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results);
        }
      });
    });
  };
  


module.exports = {
    createCaregiver,
    getAllCaregivers,
    moveCaregiverToUser,
    deleteCaregiverRequest,
    getAllHospitals
};
