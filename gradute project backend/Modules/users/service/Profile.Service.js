const db = require('../../../db/database');
const {filecreate,filedelete}= require('../../fileMannager/services/FileMannager.service');

const getUserDataById = (userId) => {
  return new Promise((resolve, reject) => {
    // First, get the user data
    const queryUser = 'SELECT * FROM users WHERE User_id = ?';
    
    db.query(queryUser, [userId], (err, userResults) => {
      if (err) {
        reject(err);
        return;
      }
      if (!userResults || userResults.length === 0) {
        reject('User not found');
        return;
      }

      const userData = userResults[0];

      // Now, if there is an image_id, query the filemannager table
      if (userData.image_id) {
        const queryImage = 'SELECT * FROM filemannager WHERE file_id = ?';
        
        db.query(queryImage, [userData.image_id], (err, imageResults) => {
          if (err) {
            reject(err);
            return;
          }
          if (imageResults && imageResults.length > 0) {
            // Add the image path to the user data
            userData.image_path = imageResults[0].path;
          } else {
            // If no image found, set a default image path
            userData.image_path = 'https://via.placeholder.com/150'; // You can set a default image path if no image is found
          }
          
          resolve(userData);
        });
      } else {
        // If no image_id, return the user data without an image
        userData.image_path = 'https://via.placeholder.com/150'; // Default image
        resolve(userData);
      }
    });
  });
};

const updateBio = (userId, bio) => {
    return new Promise((resolve, reject) => {
      const query = 'UPDATE users SET Bio = ? WHERE User_id = ?';
      db.query(query, [bio, userId], (err, result) => {
        if (err) {
          console.error('Database error:', err);
          return reject(err);
        }
        resolve(result);
      });
    });
  };
  

  const updateage = (userId, bio) => {
    return new Promise((resolve, reject) => {
      const query = 'UPDATE users SET Age = ? WHERE User_id = ?';
      db.query(query, [bio, userId], (err, result) => {
        if (err) {
          console.error('Database error:', err);
          return reject(err);
        }
        resolve(result);
      });
    });
  };

  const updateImage = async (user_id, file) => {
    return new Promise(async (resolve, reject) => {
      try {
        // Get the current file_id from the users table based on user_id
        const queryFileID = 'SELECT image_id FROM users WHERE user_id = ?';
        db.query(queryFileID, [user_id], async (err, results) => {
          if (err) {
            return reject(err);
          }
  
          if (results.length === 0) {
            return reject(new Error('User not found'));
          }
  
          const file_id = results[0].file_id;
  
          // If there is an old file, delete it from the file manager database (not the file system)
          if (file_id) {
            const queryDeleteFile = 'DELETE FROM filemannager WHERE file_id = ?';
            db.query(queryDeleteFile, [file_id], (err, deleteResults) => {
              if (err) {
                console.error('Error deleting file from file manager:', err);
                return reject(new Error('Failed to delete file from the file manager'));
              }
  
              if (deleteResults.affectedRows === 0) {
                console.error('No file found in file manager for deletion');
              }
  
              // Create the new file and insert it into the database
              filecreate(file).then(newFileId => {
                // Update the user's image_id with the new file_id
                const queryUpdateImage = 'UPDATE users SET image_id = ? WHERE user_id = ?';
                db.query(queryUpdateImage, [newFileId, user_id], (err, updateResults) => {
                  if (err) {
                    return reject(err);
                  }
  
                  if (updateResults.affectedRows > 0) {
                    resolve({ message: 'Image updated successfully', file_id: newFileId });
                  } else {
                    reject(new Error('Image update failed - No rows affected'));
                  }
                });
              }).catch(err => {
                console.error('Error creating new file:', err);
                reject(new Error('Failed to create new file'));
              });
            });
          } else {
            // If there is no old file, directly proceed to create a new file
            filecreate(file).then(newFileId => {
              const queryUpdateImage = 'UPDATE users SET image_id = ? WHERE user_id = ?';
              db.query(queryUpdateImage, [newFileId, user_id], (err, updateResults) => {
                if (err) {
                  return reject(err);
                }
  
                if (updateResults.affectedRows > 0) {
                  resolve({ message: 'Image updated successfully', file_id: newFileId });
                } else {
                  reject(new Error('Image update failed - No rows affected'));
                }
              });
            }).catch(err => {
              console.error('Error creating new file:', err);
              reject(new Error('Failed to create new file'));
            });
          }
        });
      } catch (err) {
        console.error('Error in updateImage service:', err);
        reject(err);
      }
    });
  };
  
    

module.exports = { getUserDataById ,updateBio,updateage,updateImage};
