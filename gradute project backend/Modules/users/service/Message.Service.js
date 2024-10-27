const db = require('../../../db/database');

const sendMessageToDb = async (sender_id, receiver_id, message) => {
    const sql = `
        INSERT INTO messages (sender_id, receiver_id, message, timestamp)
        VALUES (?, ?, ?, NOW())
    `;
    return new Promise((resolve, reject) => {
        db.query(sql, [sender_id, receiver_id, message], (err, results) => {
            if (err) {
                console.error("Error inserting message:", err); // Add logging
                return reject(err);
            }
            resolve({ id: results.insertId, sender_id, receiver_id, message });
        });
    });
};

const getMessagesBetweenUsers = (userId, otherUserId) => {
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
            resolve(results);
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

module.exports = {
    sendMessageToDb,
    getMessagesBetweenUsers,
    getAllUserConversations,
};
