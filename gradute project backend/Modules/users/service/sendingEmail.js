// services/emailService.js
const nodemailer = require('nodemailer');
require('dotenv').config();

const sendVerificationEmail = async (email, code) => {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user:"ahmadhawwari1092@gmail.com",
      pass: "osby jegm knyv grrq",
    },
  });

  const mailOptions = {
    from: "SafeAging",
    to: email,
    subject: 'SafeAging Verification Code',
    text: `Your verification code is: ${code}`,
  };

  // Send email and handle errors
  try {
    await transporter.sendMail(mailOptions);
    return true; // Email sent successfully
  } catch (error) {
    console.error('Error sending email:', error);
    return false; // Failed to send email
  }
};

module.exports = {
  sendVerificationEmail,
};
