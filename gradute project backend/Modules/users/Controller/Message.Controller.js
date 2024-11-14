const { validationResult } = require('express-validator');
const messageService = require('../service/Message.Service');

const sendMessage = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).json({ errors: errors.array() });
    }

    const { sender_id, receiver_id, message } = req.body;

    try {
        const userId = req.user.id;
        const result = await messageService.sendMessageToDb(userId, receiver_id, message);

        // Check if the receiver has an active WebSocket connection
        const recipientSocket = activeConnections.get(receiver_id.toString());
        if (recipientSocket) {
            // Send notification directly through WebSocket
            recipientSocket.send(JSON.stringify({
                title: 'New Message',
                body: `${sender_id} sent you a message: ${message}`,
            }));
        } else {
            // If the recipient is offline, send a Firebase notification
            const recipient = await messageService.getUserById(receiver_id);
            if (recipient && recipient.fcmToken) {
                const notification = {
                    notification: {
                        title: 'New Message',
                        body: `${sender_id} sent you a message: ${message}`,
                    },
                    token: recipient.fcmToken,
                };

                admin.messaging().send(notification)
                    .then((response) => {
                        console.log('Notification sent successfully:', response);
                    })
                    .catch((error) => {
                        console.error('Error sending notification:', error);
                    });
            }
        }

        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Failed to send message' });
    }
};



// Get messages between the logged-in user and a specific user
const getMessagesWithUser = async (req, res) => {
    const userId = req.user.id; // Get the logged-in user's ID from the request object
    const { otherUserId } = req.params; // Get the other user's ID from the request parameters

    try {
        const messages = await messageService.getMessagesBetweenUsers(userId, otherUserId);
        res.json(messages);
    } catch (error) {
        res.status(500).json({ error: 'Database error' });
    }
};


const getAllConversations = async (req, res) => {
    const userId = req.user.id;
    
    try {
        const conversations = await messageService.getAllUserConversations(userId);
        
        const conversationsWithUnreadFlag = await Promise.all(conversations.map(async (conv) => ({
            user_id: conv.user_id,
            user_email: conv.user_email,
            last_message_time: conv.last_message_time,
            image_url: conv.image_path ? `http://localhost:3001/${conv.image_path}` : null,
            hasUnreadMessages: await messageService.hasUnreadMessages(userId, conv.user_id)
        })));
        
        res.json(conversationsWithUnreadFlag);
    } catch (error) {
        console.error("Error fetching conversations:", error);
        res.status(500).json({ error: 'Database error' });
    }
};

const markMessageAsRead = async (req, res) => {
    const userId = req.user.id;  // Get logged-in user's ID from the request
    const { otherUserId } = req.params;  // Get otherUserId from the route parameter

    try {
        const result = await messageService.updateMessagesAsRead(userId, otherUserId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Failed to mark messages as read' });
    }
};





module.exports = {
    sendMessage,
    getMessagesWithUser,
    getAllConversations,
    markMessageAsRead
};
