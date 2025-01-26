const db = require('../../../db/database');

const getUsersExceptAdmin = () => {
    return new Promise((resolve, reject) => {
        const sql = "SELECT User_id, Email, Type_oftheuser FROM users WHERE Type_oftheuser != 'Admin'";
        
        db.query(sql, (error, results) => {
            if (error) {
                console.error('Database query error:', error);
                return reject(error); 
            }
            console.log('Query Result:', results);
            if (results && results.length > 0) {
                resolve(results); 
            } else {
                console.log('No users found with Type_oftheuser != "Admin".');
                resolve([]);  
            }
        });
    });
};

const deleteUserById = (id) => {
    return new Promise((resolve, reject) => {
      const deleteMessages = 'DELETE FROM messages WHERE sender_id = ? OR receiver_id = ?';
      const deleteReports = 'DELETE FROM mymedicalreports WHERE user_id = ?';
      const deleteSchedules = 'DELETE FROM schedule WHERE id = ?';
      const deleteCareRecipient = 'DELETE FROM carerecipientlist WHERE Care_giverid = ? OR carerecipient_id = ?';
  
      db.query(deleteMessages, [id, id], (err, res) => {
        if (err) return reject(err);
  
        db.query(deleteReports, [id], (err, res) => {
          if (err) return reject(err);
  
          db.query(deleteSchedules, [id], (err, res) => {
            if (err) return reject(err);
  
            db.query(deleteCareRecipient, [id, id], (err, res) => {
              if (err) return reject(err);
  
              // Finally delete the user
              const sql = 'DELETE FROM users WHERE User_id = ?';
              db.query(sql, [id], (error, results) => {
                if (error) {
                  console.error('Database query error:', error);
                  return reject(error);
                }
                resolve(results);
              });
            });
          });
        });
      });
    });
  };
  

module.exports = { getUsersExceptAdmin,deleteUserById };
