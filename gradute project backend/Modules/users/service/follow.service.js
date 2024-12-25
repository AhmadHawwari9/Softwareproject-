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
    const query = `
      SELECT 
        n.Notifications_id, 
        n.Sender_id, 
        n.reciver_id, 
        n.typeofnotifications, 
        n.is_read, 
        sender.Email AS sender_email, 
        receiver.Email AS receiver_email, 
        n.created_at
      FROM notifications n
      JOIN users sender ON sender.User_id = n.Sender_id
      JOIN users receiver ON receiver.User_id = n.reciver_id
      WHERE n.reciver_id = ?
      ORDER BY n.created_at DESC; -- Order by the latest notifications
    `;
    const values = [userId];

    db.query(query, values, (error, results) => {
      if (error) {
        console.error('Error fetching notifications: ', error);
        return reject({ error: 'Database error' });
      }
      resolve(results);
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
          n.created_at, -- Include the created_at field
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
        const deleteQuery = `
            DELETE FROM notifications 
            WHERE Sender_id = ? AND reciver_id = ? AND typeofnotifications = 'follow'
        `;
        const insertCareRecipientQuery = `
            INSERT INTO carerecipientlist (Care_giverid, carerecipient_id) 
            VALUES (?, ?)
        `;
        const insertNotificationQuery = `
            INSERT INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read) 
            VALUES (?, ?, 'approve_follow_request', 0)
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

                // Execute insert into carerecipientlist
                db.query(insertCareRecipientQuery, [receiverId, senderId], (insertCareError, insertCareResults) => {
                    if (insertCareError) {
                        console.error('Error inserting into carerecipientlist: ', insertCareError);
                        return db.rollback(() => reject({ error: 'Database error during insert' }));
                    }

                    // Execute insert notification query
                    db.query(insertNotificationQuery, [receiverId, senderId], (insertNotifError, insertNotifResults) => {
                        if (insertNotifError) {
                            console.error('Error inserting notification: ', insertNotifError);
                            return db.rollback(() => reject({ error: 'Database error during notification insert' }));
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
      SELECT Notifications_id, Sender_id, reciver_id, typeofnotifications, is_read, created_at
      FROM notifications
      WHERE Sender_id = ? AND typeofnotifications = 'unfollow'
      ORDER BY created_at DESC; -- Order by the latest notifications
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


const notificationAndUnfollowService = (senderId, receiverId) => {
  return new Promise((resolve, reject) => {
    const deleteNotificationQuery = `
      DELETE FROM notifications
      WHERE Sender_id = ? AND reciver_id = ? AND typeofnotifications = 'unfollow';
    `;

    const deleteUnfollowRequestQuery = `
      DELETE FROM carerecipientlist
      WHERE Care_giverid = ? AND carerecipient_id = ?;
    `;

    const insertNotificationQuery = `
      INSERT INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read) 
      VALUES (?, ?, 'approve_unfollow_request', 0);
    `;

    // Start by deleting the unfollow request notification
    db.query(deleteNotificationQuery, [senderId, receiverId], (notificationError, notificationResults) => {
      if (notificationError) {
        console.error('Error deleting notification: ', notificationError);
        return reject({ error: 'Database error while deleting notification' });
      }

      // If the notification is successfully deleted, proceed to delete the unfollow request
      db.query(deleteUnfollowRequestQuery, [receiverId, senderId], (unfollowError, unfollowResults) => {
        if (unfollowError) {
          console.error('Error deleting unfollow request: ', unfollowError);
          return reject({ error: 'Database error while deleting unfollow request' });
        }

        // Insert a notification for the approval of the unfollow request
        db.query(insertNotificationQuery, [receiverId, senderId], (insertError, insertResults) => {
          if (insertError) {
            console.error('Error inserting approval notification: ', insertError);
            return reject({ error: 'Database error while inserting approval notification' });
          }

          // Resolve the promise with all results
          resolve({
            notificationResults,
            unfollowResults,
            insertResults,
            affectedRows: notificationResults.affectedRows + unfollowResults.affectedRows + insertResults.affectedRows
          });
        });
      });
    });
  });
};



const notificationAndUnfollowServiceforcarerecipant = (senderId, receiverId) => {
  return new Promise((resolve, reject) => {
    const deleteNotificationQuery = `
      DELETE FROM notifications
      WHERE Sender_id = ? AND reciver_id = ? AND typeofnotifications = 'unfollow';
    `;
    
    const deleteUnfollowRequestQuery = `
      DELETE FROM carerecipientlist
      WHERE Care_giverid = ? AND carerecipient_id = ?;
    `;

    const insertNotificationQuery = `
      INSERT INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read) 
      VALUES (?, ?, 'approve_unfollow_request', 0);
    `;

    console.log('Deleting notification for:', senderId, receiverId);

    db.query(deleteNotificationQuery, [senderId, receiverId], (notificationError, notificationResults) => {
      if (notificationError) {
        console.error('Error deleting notification: ', notificationError);
        return reject({ error: 'Database error while deleting notification' });
      }

      console.log('Notification deleted, rows affected:', notificationResults.affectedRows);

      db.query(deleteUnfollowRequestQuery, [senderId, receiverId], (unfollowError, unfollowResults) => {
        if (unfollowError) {
          console.error('Error deleting unfollow request: ', unfollowError);
          return reject({ error: 'Database error while deleting unfollow request' });
        }

        console.log('Unfollow request deleted, rows affected:', unfollowResults.affectedRows);

        db.query(insertNotificationQuery, [receiverId, senderId], (insertError, insertResults) => {
          if (insertError) {
            console.error('Error inserting approval notification: ', insertError);
            return reject({ error: 'Database error while inserting approval notification' });
          }

          console.log('Approval notification inserted, rows affected:', insertResults.affectedRows);

          resolve({
            notificationResults,
            unfollowResults,
            insertResults,
            affectedRows: notificationResults.affectedRows + unfollowResults.affectedRows + insertResults.affectedRows
          });
        });
      });
    });
  });
};






const getNotificationCountForUser = (userId) => {
  return new Promise((resolve, reject) => {
    const query = `
      SELECT COUNT(*) AS unread_count
      FROM notifications
      WHERE reciver_id = ? AND is_read = 0
    `;

    const values = [userId]; 

    db.query(query, values, (error, results) => {
      if (error) {
        console.error('Error fetching notification count: ', error);
        return reject({ error: 'Database error' });
      }
      resolve(results[0].unread_count);
    });
  });
};

const markAllNotificationsAsReadForUser = (userId) => {
  return new Promise((resolve, reject) => {
    const query = `
      UPDATE notifications
      SET is_read = 1
      WHERE reciver_id = ?
    `;

    const values = [userId]; // Use user ID as the parameter

    db.query(query, values, (error, results) => {
      if (error) {
        console.error('Error updating notifications: ', error);
        return reject({ error: 'Database error' });
      }

      resolve(results.affectedRows); // Number of rows updated
    });
  });
};


module.exports = { sendFollowNotification,getNotificationsByUserId,
  getNotificationsForUser,removeFollowRequest,approveFollowRequestService,removeFollowRequestService,
  getCareGiversForRecipient,
  sendUnfollowNotification,
  removeUnfollowNotification,
  fetchUnfollowNotifications,
  deleteNotificationService,
  notificationAndUnfollowService,
  notificationAndUnfollowServiceforcarerecipant,
  getNotificationCountForUser,
  markAllNotificationsAsReadForUser
};

