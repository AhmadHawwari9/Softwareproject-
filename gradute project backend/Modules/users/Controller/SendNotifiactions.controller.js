const asyncHandler = require("express-async-handler");

const sendNotificationService = require("../service/SendNotifiactions.service");

const sendNotificationController = asyncHandler(async (req, res) => {
  const notificationData = req.body;
  const notification = await sendNotificationService(notificationData);
  res.status(200).json({
    success: true,
    message: "Notification sent successfully",
    notification: notification,
  });
});


module.exports = sendNotificationController;