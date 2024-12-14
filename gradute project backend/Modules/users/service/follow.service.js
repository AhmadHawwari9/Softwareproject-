const db = require('../../../db/database'); 

const sendFollowNotification = (sender_id, reciver_id) => {
  return new Promise((resolve, reject) => {
    const query = `
      INSERT INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read) 
      VALUES (?, ?, 'follow', 0)
    `;
    const values = [sender_id, reciver_id];

    db.query(query, values, (error, results) => {
      if (error) {
        console.error('Error inserting follow notification: ', error);
        return reject({ error: 'Database error' });
      }

      resolve({ notification_id: results.insertId, sender_id, reciver_id });
    });
  });
};


const getNotificationsByUserId = (userId) => {
    return new Promise((resolve, reject) => {
      // SQL query with JOIN to fetch the sender and receiver emails
      const query = `
        SELECT 
          n.Notifications_id, 
          n.Sender_id, 
          n.reciver_id, 
          n.typeofnotifications, 
          n.is_read, 
          sender.Email AS sender_email, 
          receiver.Email AS receiver_email
        FROM notifications n
        JOIN users sender ON sender.User_id = n.Sender_id
        JOIN users receiver ON receiver.User_id = n.reciver_id
        WHERE n.reciver_id = ? AND n.is_read = 0
      `;
      const values = [userId];  // Use the user ID as a parameter
  
      // Execute the query
      db.query(query, values, (error, results) => {
        if (error) {
          console.error('Error fetching notifications: ', error);
          return reject({ error: 'Database error' });
        }
        resolve(results);  // Resolve the query with the results
      });
    });
  };
  

  const getNotificationsForUser = (userId) => {
    return new Promise((resolve, reject) => {
      // SQL query to fetch notifications where sender_id is equal to userId
      const query = `
        SELECT 
          n.Notifications_id, 
          n.Sender_id, 
          n.reciver_id, 
          n.typeofnotifications, 
          n.is_read, 
          sender.Email AS sender_email, 
          receiver.Email AS receiver_email
        FROM notifications n
        JOIN users sender ON sender.User_id = n.Sender_id
        JOIN users receiver ON receiver.User_id = n.reciver_id
        WHERE n.Sender_id = ? AND n.typeofnotifications = 'follow'
      `;
  
      const values = [userId];  // Use the user ID as a parameter
  
      // Execute the query
      db.query(query, values, (error, results) => {
        if (error) {
          console.error('Error fetching notifications: ', error);
          return reject({ error: 'Database error' });
        }
        resolve(results);  // Resolve the query with the results
      });
    });
  };
  

  const removeFollowRequest = (senderId, receiverId) => {
    return new Promise((resolve, reject) => {
      const query = `
        DELETE FROM notifications
        WHERE Sender_id = ? AND reciver_id = ? AND typeofnotifications = 'follow'
      `;
  
      const values = [senderId, receiverId];  
  
      db.query(query, values, (error, results) => {
        if (error) {
          console.error('Error deleting follow request: ', error);
          return reject({ error: 'Database error' });
        }
        resolve(results);  
      });
    });
  };
  
  const approveFollowRequestService = (senderId, receiverId) => {
    return new Promise((resolve, reject) => {
        // SQL queries for deleting from `notifications` and inserting into `carerecipientlist`
        const deleteQuery = `
            DELETE FROM notifications 
            WHERE Sender_id = ? AND reciver_id = ? AND typeofnotifications = 'follow'
        `;
        const insertQuery = `
            INSERT INTO carerecipientlist (Care_giverid, carerecipient_id) 
            VALUES (?, ?)
        `;

        // Start a transaction
        db.beginTransaction((transactionError) => {
            if (transactionError) {
                console.error('Error starting transaction: ', transactionError);
                return reject({ error: 'Transaction error' });
            }

            // Execute delete query
            db.query(deleteQuery, [senderId, receiverId], (deleteError, deleteResults) => {
                if (deleteError) {
                    console.error('Error deleting follow request: ', deleteError);
                    return db.rollback(() => reject({ error: 'Database error during delete' }));
                }

                // Execute insert query
                db.query(insertQuery, [receiverId, senderId], (insertError, insertResults) => {
                    if (insertError) {
                        console.error('Error inserting into carerecipientlist: ', insertError);
                        return db.rollback(() => reject({ error: 'Database error during insert' }));
                    }

                    // Commit the transaction
                    db.commit((commitError) => {
                        if (commitError) {
                            console.error('Error committing transaction: ', commitError);
                            return db.rollback(() => reject({ error: 'Transaction commit error' }));
                        }

                        resolve();
                    });
                });
            });
        });
    });
};


const removeFollowRequestService = (senderId, receiverId) => {
    return new Promise((resolve, reject) => {
        const deleteQuery = `
            DELETE FROM notifications 
            WHERE Sender_id = ? AND reciver_id = ? AND typeofnotifications = 'follow'
        `;

        db.beginTransaction((transactionError) => {
            if (transactionError) {
                console.error('Error starting transaction: ', transactionError);
                return reject({ error: 'Transaction error' });
            }

            db.query(deleteQuery, [senderId, receiverId], (deleteError, deleteResults) => {
                if (deleteError) {
                    console.error('Error removing follow request: ', deleteError);
                    return db.rollback(() => reject({ error: 'Database error during delete' }));
                }

                db.commit((commitError) => {
                    if (commitError) {
                        console.error('Error committing transaction: ', commitError);
                        return db.rollback(() => reject({ error: 'Transaction commit error' }));
                    }

                    resolve();  
                });
            });
        });
    });
};


const getCareGiversForRecipient = (userId) => {
  return new Promise((resolve, reject) => {
      // SQL query to fetch care recipients and image paths
      const query = `
          SELECT 
              cr.Care_giverid,
              u.User_id,
              u.First_name,
              u.Last_name,
              u.Email,
              u.Age,
              u.Type_oftheuser,
              u.Bio,
              fm.path AS image_path
          FROM carerecipientlist cr
          JOIN users u ON cr.Care_giverid = u.User_id
          LEFT JOIN filemannager fm ON u.image_id = fm.file_id
          WHERE cr.carerecipient_id = ?
      `;

      const values = [userId]; // Use the authenticated user's ID

      // Execute the query
      db.query(query, values, (error, results) => {
          if (error) {
              console.error('Error fetching care recipients: ', error);
              return reject({ error: 'Database error' });
          }
          resolve(results); // Resolve the query with the results
      });
  });
};

const sendUnfollowNotification = (sender_id, reciver_id) => {
  return new Promise((resolve, reject) => {
    const query = `
      INSERT INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read) 
      VALUES (?, ?, 'unfollow', 0)
    `;
    const values = [sender_id, reciver_id];

    db.query(query, values, (error, results) => {
      if (error) {
        console.error('Error inserting unfollow notification: ', error);
        return reject({ error: 'Database error' });
      }

      resolve({ notification_id: results.insertId, sender_id, reciver_id });
    });
  });
};

const removeUnfollowNotification = (senderId, receiverId) => {
  return new Promise((resolve, reject) => {
    const query = `
      DELETE FROM notifications 
      WHERE Sender_id = ? 
      AND reciver_id = ? 
      AND typeofnotifications = 'unfollow'
    `;
    const values = [senderId, receiverId];

    db.query(query, values, (error, results) => {
      if (error) {
        console.error('Error deleting unfollow notification: ', error);
        return reject({ error: 'Database error' });
      }

      resolve({ message: 'Notification deleted', notification_id: results.affectedRows });
    });
  });
};

const fetchUnfollowNotifications = (userId) => {
  return new Promise((resolve, reject) => {
    const query = `
      SELECT Notifications_id, Sender_id,reciver_id, typeofnotifications, is_read
      FROM notifications
      WHERE Sender_id = ? AND typeofnotifications = 'unfollow';
    `;

    db.query(query, [userId], (error, results) => {
      if (error) {
        console.error('Error fetching unfollow notifications: ', error);
        return reject({ error: 'Database error' });
      }

      resolve(results);
    });
  });
};

const deleteNotificationService = (senderId, receiverId) => {
  return new Promise((resolve, reject) => {
    const query = `
      DELETE FROM notifications
      WHERE Sender_id = ? AND reciver_id = ?;
    `;

    db.query(query, [senderId, receiverId], (error, results) => {
      if (error) {
        console.error('Error deleting notification: ', error);
        return reject({ error: 'Database error' });
      }

      resolve(results); // Returns the result of the delete query
    });
  });
};


module.exports = { sendFollowNotification,getNotificationsByUserId,
  getNotificationsForUser,removeFollowRequest,approveFollowRequestService,removeFollowRequestService,
  getCareGiversForRecipient,
  sendUnfollowNotification,
  removeUnfollowNotification,
  fetchUnfollowNotifications,
  deleteNotificationService
};

