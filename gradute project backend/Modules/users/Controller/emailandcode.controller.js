const { validationResult } = require('express-validator');
const bcrypt = require('bcrypt');
const { sendVerificationEmail } = require('../service/sendingEmail');
const { validateNewPassword } = require('../Validation/Emailandcode.Validation');
const mysql = require('mysql'); // Import the MySQL package

const db = require('../../../db/database'); // Import your MySQL database connection

// In-memory storage for verification codes (for demonstration purposes)
const verificationCodes = {};

const sendCode = async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email } = req.body;

  // Check if the user exists in the database
  db.query('SELECT * FROM users WHERE Email = ?', [email], async (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ message: 'Database query failed.' });
    }

    // If no user is found, return an error response
    if (results.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // If user exists, generate and send the verification code
    const code = Math.floor(100000 + Math.random() * 900000).toString(); // Generate a 6-digit code

    // Store the verification code
    verificationCodes[email] = code;

    try {
      // Send verification email
      await sendVerificationEmail(email, code);
      res.status(200).json({ message: 'Verification code sent!' });
    } catch (error) {
      console.error('Error sending email:', error);
      res.status(500).json({ message: 'Failed to send verification code.' });
    }
  });
};


const verifyCode = (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, code } = req.body;

  // Check if the email exists in verificationCodes
  if (!verificationCodes[email]) {
    return res.status(404).json({ message: 'Email not found. Please request a new verification code.' });
  }

  // Check if the code matches
  if (verificationCodes[email] === code) {
    delete verificationCodes[email]; // Optionally delete the code after successful verification
    res.status(200).json({ message: 'Code verified successfully!' });
  } else {
    res.status(400).json({ message: 'Invalid verification code.' });
  }
};


const resetPassword = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
  }

  const { email, newPassword } = req.body;

  // Hash the new password
  const hashedPassword = await bcrypt.hash(newPassword, 10);

  try {
      // Update the user's password in the MySQL database
      db.query(
          'UPDATE users SET Password = ? WHERE Email = ?',
          [hashedPassword, email],
          (error, results) => {
              if (error) {
                  console.error('Error executing query:', error);
                  return res.status(500).json({ message: 'Failed to reset password.' });
              }

              if (results.affectedRows === 0) {
                  return res.status(404).json({ message: 'User not found.' });
              }

              delete verificationCodes[email]; // Remove the code after successful verification
              res.status(200).json({ message: 'Password reset successfully!' });
          }
      );
  } catch (error) {
      console.error('Error resetting password:', error);
      res.status(500).json({ message: 'Failed to reset password.' });
  }
};


module.exports = {
  sendCode,
  verifyCode,
  resetPassword,
};
