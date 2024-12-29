const db = require('../../../db/database');

const updateEmail = (userId, newEmail) => {
    return new Promise((resolve, reject) => {
      const selectQuery = `SELECT Email, First_name FROM users WHERE User_id = ?`;
  
      console.log("Running query with userId:", userId);  // Log the userId to verify
  
      db.query(selectQuery, [userId], (err, results) => {
        if (err) {
          console.error("Error during SELECT query:", err);
          reject(err);
        } else {
          if (results.length === 0) {
            console.log("User not found for userId:", userId);  // Log if user is not found
            reject(new Error('User ID not found'));
          } else {
            const updateQuery = `UPDATE users SET Email = ? WHERE User_id = ?`;
            
            db.query(updateQuery, [newEmail, userId], (err, updateResult) => {
              if (err) {
                console.error("Error during UPDATE query:", err);
                reject(err);
              } else {
                if (updateResult.affectedRows === 0) {
                  reject(new Error('Email update failed'));
                } else {
                  resolve({
                    message: `Email updated successfully for user: ${results[0].First_name}`,
                  });
                }
              }
            });
          }
        }
      });
    });
  };


  const changeUserPassword = (userId, hashedPassword) => {
    return new Promise((resolve, reject) => {
      const query = 'UPDATE users SET Password = ? WHERE User_id = ?';
      const values = [hashedPassword, userId];
  
      db.query(query, values, (error, results) => {
        if (error) {
          console.error('Error updating password: ', error);
          return reject({ error: 'Database error' });
        }
  
        if (results.affectedRows === 0) {
          return reject({ error: 'User not found' });
        }
  
        resolve({ message: 'Password updated successfully' });
      });
    });
  };
  
  const deleteUserById = (userId) => {
    return new Promise((resolve, reject) => {
      // First, delete the dependent records in the carerecipientlist
      const deleteDependentQuery = 'DELETE FROM carerecipientlist WHERE carerecipient_id = ?';
      db.query(deleteDependentQuery, [userId], (err, deleteResults) => {
        if (err) {
          console.error('Error deleting dependent records: ', err);
          return reject({ error: 'Error deleting dependent records' });
        }
  
        // Now, delete the user
        const query = 'DELETE FROM users WHERE User_id = ?';
        db.query(query, [userId], (error, results) => {
          if (error) {
            console.error('Error deleting user: ', error);
            return reject({ error: 'Database error' });
          }
  
          if (results.affectedRows === 0) {
            return reject({ error: 'User not found' });
          }
  
          resolve({ message: 'User deleted successfully' });
        });
      });
    });
  };
  
  
module.exports = {
  updateEmail,
  changeUserPassword,
  deleteUserById
};
