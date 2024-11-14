// validations/emailValidation.js
const { body } = require('express-validator');

const validateEmail = [
  body('email').isEmail().withMessage('Invalid email address'),
];

const validateCode = [
  body('email').isEmail().withMessage('Invalid email address'),
  body('code').isLength({ min: 6, max: 6 }).withMessage('Code must be 6 digits long'),
];


const validateNewPassword = [
  body('email').isEmail().withMessage('Invalid email address'),
  body('newPassword')
    .isLength({ min: 8})
    .withMessage('Password must be at least 8 characters long')
    .matches(/[0-9]/)
    .withMessage('Password must contain at least one number')
    .matches(/[a-zA-Z]/)
    .withMessage('Password must contain at least one letter'),
];

module.exports = {
  validateEmail,
  validateCode,
  validateNewPassword
};