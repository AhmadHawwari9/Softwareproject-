const { validationResult } = require('express-validator');
const messageService = require('../service/Message.Service');

// Send a message to a specific receiver
const sendMessage = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).json({ errors: errors.array() });
    }

    const { sender_id, receiver_id, message } = req.body;

    try {
        const result = await messageService.sendMessageToDb(sender_id, receiver_id, message);
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
    console.log("Logged in user ID:", userId); // Debugging
    
    try {
        const conversations = await messageService.getAllUserConversations(userId);
        console.log("Conversations found:", conversations); // Debugging
        res.json(conversations.map(conv => ({
            user_id: conv.user_id,
            user_email: conv.user_email,  // Include email in the response
            last_message_time: conv.last_message_time
        })));
    } catch (error) {
        console.error("Error fetching conversations:", error);
        res.status(500).json({ error: 'Database error' });
    }
};


module.exports = {
    sendMessage,
    getMessagesWithUser,
    getAllConversations,
};
