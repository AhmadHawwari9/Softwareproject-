const { validationResult } = require('express-validator');
const messageService = require('../service/Message.Service');
const filemannager = require('../../fileMannager/services/FileMannager.service');

const sendMessage = async (req, res) => {
    const userId = req.user.id;
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).json({ errors: errors.array() });
    }

    const { sender_id, receiver_id, message } = req.body;

    // Check if both message and photo or audio are provided
    if (message && (req.files?.photo || req.files?.audio)) {
        return res.status(400).json({ error: 'You can only send either a message, a photo, or an audio file, not both.' });
    }

    try {
        let img_id = null; // Set img_id to null by default
        let audio_id = null; // Set audio_id to null by default

        // If message is present, save it to the database
        if (message) {
            const result = await messageService.sendMessageToDb(userId, receiver_id, message, img_id, audio_id);
            return res.status(201).json(result);
        }
        
        // If a photo is uploaded
        else if (req.files?.photo) {
            // Save the uploaded photo in the file manager
            const photo = req.files.photo[0];
            img_id = await filemannager.filecreate(photo);
            
            // Save the photo path in the messages table
            const photoPath = `Uploade/${photo.filename}`;
            const result = await messageService.sendMessageToDb(userId, receiver_id, photoPath, img_id, audio_id);
            return res.status(201).json(result);
        }

        // If an audio file is uploaded
        else if (req.files?.audio) {
            // Save the uploaded audio file in the file manager
            const audio = req.files.audio[0];
            audio_id = await filemannager.filecreate(audio);

            // Save the audio path in the messages table
            const audioPath = `Uploade/${audio.filename}`;
            const result = await messageService.sendMessageToDb(userId, receiver_id, audioPath, img_id, audio_id);
            return res.status(201).json(result);
        }

        else {
            return res.status(400).json({ error: 'No message, photo, or audio provided.' });
        }
    } catch (error) {
        console.error('Error sending message:', error);
        return res.status(500).json({ error: 'Failed to send message' });
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



const fetchUnreadMessageCount = async (req, res) => {
    const userId = req.user.id;  // Extract receiver_id from the authenticated user
    
    try {
      const unreadMessageCount = await  messageService.getUnreadMessageCountForUser(userId);
  
      return res.status(200).json({
        message: "Unread message count fetched successfully",
        unreadMessageCount,
      });
    } catch (error) {
      console.error('Error fetching unread message count: ', error);
      return res.status(500).json({
        error: "An error occurred while fetching unread message count",
      });
    }
  };
  

module.exports = {
    sendMessage,
    getMessagesWithUser,
    getAllConversations,
    markMessageAsRead,
    fetchUnreadMessageCount
};
