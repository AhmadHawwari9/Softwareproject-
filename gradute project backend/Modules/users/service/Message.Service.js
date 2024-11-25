const db = require('../../../db/database');

const sendMessageToDb = async (sender_id, receiver_id, message, img_id, audio_id) => {
    const sql = `
        INSERT INTO messages (sender_id, receiver_id, message, img_id, Audio_id, timestamp)
        VALUES (?, ?, ?, ?, ?, NOW())
    `;
    return new Promise((resolve, reject) => {
        db.query(sql, [sender_id, receiver_id, message, img_id, audio_id], (err, results) => {
            if (err) {
                console.error("Error inserting message:", err); // Add logging
                return reject(err);
            }
            resolve({ 
                id: results.insertId, 
                sender_id, 
                receiver_id, 
                message, 
                img_id, 
                audio_id 
            });
        });
    });
};



const getMessagesBetweenUsers = (userId, otherUserId) => {
    const sql = `
        SELECT 
            m.*, 
            CASE 
                WHEN m.sender_id = ? THEN 'You' 
                ELSE sender_user.Email 
            END AS sender_email,
            receiver_user.Email AS receiver_email,
            CASE 
                WHEN m.img_id IS NOT NULL THEN (
                    SELECT f.path 
                    FROM filemannager f 
                    WHERE f.file_id = m.img_id
                )
                ELSE NULL 
            END AS path
        FROM messages m
        JOIN users AS sender_user ON m.sender_id = sender_user.User_id
        JOIN users AS receiver_user ON m.receiver_id = receiver_user.User_id
        WHERE (m.sender_id = ? AND m.receiver_id = ?)
           OR (m.sender_id = ? AND m.receiver_id = ?)
        ORDER BY m.timestamp ASC
    `;

    return new Promise((resolve, reject) => {
        db.query(sql, [userId, userId, otherUserId, otherUserId, userId], (err, results) => {
            if (err) {
                console.error("Error fetching messages:", err);
                return reject(err);
            }

            resolve(
                results.map((message) => ({
                    ...message,
                    file: message.file_path
                        ? { type: 'file', path: message.file_path }
                        : null,
                }))
            );
        });
    });
};



const getAllUserConversations = (userId) => {
    const sql = `
        SELECT DISTINCT 
            CASE 
                WHEN sender_id = ? THEN receiver_id 
                ELSE sender_id 
            END AS user_id,
            u.Email AS user_email,
            MAX(m.timestamp) AS last_message_time
        FROM messages m
        JOIN users u ON (u.User_id = CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END)
        WHERE sender_id = ? OR receiver_id = ?
        GROUP BY user_id, u.Email 
        ORDER BY last_message_time DESC
    `;

    return new Promise((resolve, reject) => {
        db.query(sql, [userId, userId, userId, userId], (err, results) => {
            if (err) {
                console.error("Error fetching user conversations:", err); // Add logging
                return reject(err);
            }
            resolve(results);
        });
    });
};
const getUserById = (userId) => {
    const sql = 'SELECT User_id, Email, fcmToken FROM users WHERE User_id = ?';

    return new Promise((resolve, reject) => {
        db.query(sql, [userId], (err, results) => {
            if (err) {
                console.error("Error fetching user:", err);
                return reject(err);
            }
            resolve(results[0]); 
        });
    });
};

const hasUnreadMessages = async (userId, otherUserId) => {
    const sql = `
        SELECT COUNT(*) as unreadCount
        FROM messages
        WHERE receiver_id = ? AND sender_id = ? AND is_read = 0
    `;
    return new Promise((resolve, reject) => {
        db.query(sql, [userId, otherUserId], (err, results) => {
            if (err) {
                console.error("Error fetching unread messages:", err);
                return reject(err);
            }
            resolve(results[0].unreadCount > 0);
        });
    });
};

const updateMessagesAsRead = (userId, otherUserId) => {
    const sql = `
        UPDATE messages 
        SET is_read = 1 
        WHERE receiver_id = ? AND sender_id = ? AND is_read = 0
    `;
    
    return new Promise((resolve, reject) => {
        console.log(`Executing query: ${sql} with userId: ${userId}, otherUserId: ${otherUserId}`);
        
        db.query(sql, [userId, otherUserId], (err, results) => {
            if (err) {
                console.error("Error marking messages as read:", err);
                return reject(err);
            }

            console.log(`Rows affected: ${results.affectedRows}`);
            resolve(results);
        });
    });
};

const getUnreadMessagesCount = async (userId) => {
    const sql = `
        SELECT COUNT(*) as unreadCount
        FROM messages
        WHERE receiver_id = ? AND is_read = 0
    `;
    return new Promise((resolve, reject) => {
        db.query(sql, [userId], (err, results) => {
            if (err) {
                console.error("Error fetching unread messages count:", err);
                return reject(err);
            }
            resolve(results[0].unreadCount);
        });
    });
};


const getUnreadMessages = async (userId) => {
    const sql = `
        SELECT m.*, 
               CASE 
                   WHEN m.sender_id = ? THEN 'You' 
                   ELSE sender_user.Email 
               END AS sender_email,
               receiver_user.Email AS receiver_email
        FROM messages m
        JOIN users AS sender_user ON m.sender_id = sender_user.User_id
        JOIN users AS receiver_user ON m.receiver_id = receiver_user.User_id
        WHERE m.receiver_id = ? AND m.is_read = 0
        ORDER BY m.timestamp ASC
    `;
    return new Promise((resolve, reject) => {
        db.query(sql, [userId, userId], (err, results) => {
            if (err) {
                console.error("Error fetching unread messages:", err);
                return reject(err);
            }
            resolve(results); // This will return the unread messages
        });
    });
};


module.exports = {
    sendMessageToDb,
    getMessagesBetweenUsers,
    getAllUserConversations,
    getUserById, 
    hasUnreadMessages,
    updateMessagesAsRead,
    getUnreadMessagesCount,
    getUnreadMessages
};