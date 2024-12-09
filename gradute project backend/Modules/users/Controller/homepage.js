const messageService = require('../service/Message.Service');
const {getUserType}=require('../service/getusertype.service');

const homepagecontroller = async (req, res) => {
    const userId = req.user.id; // Get the logged-in user's ID from the request object

    try {
        // Fetch unread messages count
        const unreadMessagesCount = await messageService.getUnreadMessagesCount(userId);

        // Fetch all unread messages
        const unreadMessages = await messageService.getUnreadMessages(userId);

        // Fetch user type
        const userType = await getUserType(userId);

        // Return unread messages, count, and user type
        res.json({
            message: 'Welcome to the Homepage!',
            notifications: {
                unreadMessagesCount: unreadMessagesCount,
            },
            unreadMessages: unreadMessages, // Include the unread messages
            userType: userType // Include the user type
        });
    } catch (error) {
        console.error("Error fetching notifications:", error);
        res.status(500).json({ error: 'Failed to fetch notifications' });
    }
};

module.exports = {
    homepagecontroller
};
