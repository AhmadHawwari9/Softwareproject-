const { sendFollowNotification ,getNotificationsByUserId,
  getNotificationsForUser,removeFollowRequest,approveFollowRequestService,
  removeFollowRequestService,getCareGiversForRecipient,
  sendUnfollowNotification,
  removeUnfollowNotification,fetchUnfollowNotifications,deleteNotificationService,
  notificationAndUnfollowService,
  notificationAndUnfollowServiceforcarerecipant,getNotificationCountForUser,
  markAllNotificationsAsReadForUser} = require('../service/follow.service');

const sendFollowRequest = async (req, res) => {
  const {  reciver_id} = req.body; // The user to be followed
  const  sender_id = req.user.id;  // The currently authenticated user

  try {
    const result = await sendFollowNotification(sender_id, reciver_id);

    return res.status(200).json({
      message: "Follow request sent successfully",
      notification: result,
    });
  } catch (error) {
    console.error('Error sending follow request: ', error);
    return res.status(500).json({
      error: "An error occurred while sending the follow request",
    });
  }
};

const getUserNotifications = async (req, res) => {
    const userId = req.user.id;  // Get the user ID from the authenticated user
    
    try {
      const notifications = await getNotificationsByUserId(userId);
  
      return res.status(200).json({
        message: "Notifications fetched successfully",
        notifications,
      });
    } catch (error) {
      console.error('Error fetching notifications: ', error);
      return res.status(500).json({
        error: "An error occurred while fetching notifications",
      });
    }
  };

  const fetchUserNotifications = async (req, res) => {
    const userId = req.user.id;  // Get the user ID from the authenticated user
  
    try {
      const notifications = await getNotificationsForUser(userId);
  
      return res.status(200).json({
        message: "Notifications fetched successfully",
        notifications,
      });
    } catch (error) {
      console.error('Error fetching notifications: ', error);
      return res.status(500).json({
        error: "An error occurred while fetching notifications",
      });
    }
  };

  const deleteFollowRequest = async (req, res) => {
    const senderId = req.user.id;  // Get the sender ID from the authenticated user
    const receiverId = req.params.receiverId;  // Get the receiver ID from the URL
  
    try {
      const result = await removeFollowRequest(senderId, receiverId);
  
      if (result.affectedRows === 0) {
        return res.status(404).json({
          message: "Follow request not found or already deleted",
        });
      }
  
      return res.status(200).json({
        message: "Follow request deleted successfully",
      });
    } catch (error) {
      console.error('Error deleting follow request: ', error);
      return res.status(500).json({
        error: "An error occurred while deleting the follow request",
      });
    }
  };
  
  const approveFollowRequest = async (req, res) => {
    const receiverId = req.user.id; 
    const senderId = req.body.sender_id; 

    try {
        await approveFollowRequestService(senderId, receiverId);

        return res.status(200).json({
            message: "Follow request approved successfully",
        });
    } catch (error) {
        console.error('Error approving follow request: ', error);
        return res.status(500).json({
            error: "An error occurred while approving the follow request",
        });
    }
};

const removeFollowRequest1 = async (req, res) => {
    const receiverId = req.user.id;  // Receiver is the authenticated user
    const senderId = req.body.sender_id;  // Sender's ID comes from the request body

    try {
        await removeFollowRequestService(senderId, receiverId);

        return res.status(200).json({
            message: "Follow request removed successfully",
        });
    } catch (error) {
        console.error('Error removing follow request: ', error);
        return res.status(500).json({
            error: "An error occurred while removing the follow request",
        });
    }
};

const fetchCareGiversForRecipient = async (req, res) => {
  const userId = req.user.id;

  try {
     
      const careRecipients = await getCareGiversForRecipient(userId);

      return res.status(200).json({
          message: "Care recipients fetched successfully",
          careRecipients,
      });
  } catch (error) {
      console.error('Error fetching care recipients: ', error);
      return res.status(500).json({
          error: "An error occurred while fetching care recipients",
      });
  }
};

const sendUnfollowRequest = async (req, res) => {
  const { reciver_id } = req.body; 
  const sender_id = req.user.id; 

  try {
    const result = await sendUnfollowNotification(sender_id, reciver_id);

    return res.status(200).json({
      message: "Unfollow request sent successfully",
      notification: result,
    });
  } catch (error) {
    console.error('Error sending unfollow request: ', error);
    return res.status(500).json({
      error: "An error occurred while sending the unfollow request",
    });
  }
};

const deleteUnfollowRequest = async (req, res) => {
  const { receiverId } = req.params;
  const senderId = req.user.id; // Getting the sender's id from the authenticated user

  try {
    const result = await removeUnfollowNotification(senderId, receiverId); 

    return res.status(200).json({
      message: "Unfollow request deleted successfully",
      notification: result,
    });
  } catch (error) {
    console.error('Error deleting unfollow request: ', error);
    return res.status(500).json({
      error: "An error occurred while deleting the unfollow request",
    });
  }
};

const getUnfollowNotifications = async (req, res) => {
  const userId = req.user.id;

  try {
    const notifications = await fetchUnfollowNotifications(userId);

    return res.status(200).json({
      message: 'Unfollow notifications retrieved successfully',
      notifications,
    });
  } catch (error) {
    console.error('Error fetching unfollow notifications: ', error);
    return res.status(500).json({
      error: 'An error occurred while fetching notifications',
    });
  }
};

const deleteNotification = async (req, res) => {
  const senderId = req.params.senderId; 
  const receiverId = req.user.id; 

  try {
    const result = await deleteNotificationService(senderId, receiverId);

    if (result.affectedRows > 0) {
      return res.status(200).json({
        message: 'Notification deleted successfully',
      });
    } else {
      return res.status(404).json({
        message: 'Notification not found or already deleted',
      });
    }
  } catch (error) {
    console.error('Error deleting notification: ', error);
    return res.status(500).json({
      error: 'An error occurred while deleting the notification',
    });
  }
};

const handleNotificationAndUnfollowRequestDeletion = async (req, res) => {
  const senderId = req.params.senderId; 
  const receiverId = req.user.id; 

  try {
    const result = await notificationAndUnfollowService(senderId, receiverId);

    if (result.affectedRows > 0) {
      return res.status(200).json({
        message: 'Notification and unfollow request deleted successfully',
      });
    } else {
      return res.status(404).json({
        message: 'Notification or unfollow request not found or already deleted',
      });
    }
  } catch (error) {
    console.error('Error during notification and unfollow deletion: ', error);
    return res.status(500).json({
      error: 'An error occurred while deleting the notification and unfollow request',
    });
  }
};


const handleNotificationAndUnfollowRequestDeletionforcarerecipant = async (req, res) => {
  const senderId = req.params.senderId;  // Caregiver's ID from URL parameter
  const receiverId = req.user.id;  // Carerecipient's ID from the authenticated user
  
  console.log('Sender ID:', senderId);
  console.log('Receiver ID:', receiverId);

  try {
    const result = await notificationAndUnfollowServiceforcarerecipant(senderId, receiverId);

    if (result.affectedRows > 0) {
      return res.status(200).json({
        message: 'Notification and unfollow request deleted successfully',
      });
    } else {
      return res.status(404).json({
        message: 'Notification or unfollow request not found or already deleted',
      });
    }
  } catch (error) {
    console.error('Error during notification and unfollow deletion: ', error);
    return res.status(500).json({
      error: 'An error occurred while deleting the notification and unfollow request',
    });
  }
};

const fetchNotificationCount = async (req, res) => {
  const userId = req.user.id; 

  try {
    const notificationCount = await getNotificationCountForUser(userId);

    return res.status(200).json({
      message: "Notification count fetched successfully",
      notificationCount,
    });
  } catch (error) {
    console.error('Error fetching notification count: ', error);
    return res.status(500).json({
      error: "An error occurred while fetching notification count",
    });
  }
};

const markNotificationsAsRead = async (req, res) => {
  const userId = req.user.id; 

  try {
    const updatedRows = await markAllNotificationsAsReadForUser(userId);

    return res.status(200).json({
      message: "Notifications marked as read successfully",
      updatedRows, 
    });
  } catch (error) {
    console.error('Error marking notifications as read: ', error);
    return res.status(500).json({
      error: "An error occurred while marking notifications as read",
    });
  }
};


module.exports = { sendFollowRequest ,getUserNotifications,fetchUserNotifications,deleteFollowRequest,approveFollowRequest,removeFollowRequest1,
  fetchCareGiversForRecipient,
  sendUnfollowRequest,
  deleteUnfollowRequest,
  getUnfollowNotifications,
  deleteNotification,
  handleNotificationAndUnfollowRequestDeletion,
  handleNotificationAndUnfollowRequestDeletionforcarerecipant,
  fetchNotificationCount,
  markNotificationsAsRead
};
