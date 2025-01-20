
const axios = require("axios");

const ONESIGNAL_URL = "https://onesignal.com/api/v1/notifications";
const ONESIGNAL_APP_ID = "e4855ea9-18df-4a72-8296-e3a54dcdb9fe";
const ONESIGNAL_API_KEY = "os_v2_app_4scv5kiy35fhfauw4osu3tnz723kkyoqfy6uwnmw7dbnfr5g2u7sfkftpnouq4d72cuygheqn7qktold7mn5omy7i46eioijfzi45by";

const sendNotificationService = async (notificationData) => {
  const { title, message, externalIds } = notificationData;

  if (!title || !message) {
    const error = new Error("Title and message are required");
    error.statusCode = 400;
    throw error;
  }

  console.log("externalIds", externalIds);
  try {
    const oneSignalResponse = await axios.post(
      ONESIGNAL_URL,
      {
        app_id: ONESIGNAL_APP_ID,
        headings: { en: title },
        contents: { en: message },
        include_aliases: {
          external_id:
            Array.isArray(externalIds) && externalIds.length > 0
              ? externalIds
              : [externalIds],
        },
        target_channel: "push",
      },
      {
        headers: {
          Authorization: `Basic ${ONESIGNAL_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );
    console.log("oneSignalResponse", oneSignalResponse);

    return oneSignalResponse.data;
  } catch (error) {
    console.error("Error sending notification:");
    console.error(error.response.data);
    throw new Error("Failed to send notification");
  }
};

module.exports = sendNotificationService;