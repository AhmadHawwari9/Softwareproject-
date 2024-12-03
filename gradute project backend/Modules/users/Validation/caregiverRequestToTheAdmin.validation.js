const { body } = require('express-validator');

const First_name = body('first_name').notEmpty().withMessage('First name is required');
const Last_name = body('last_name').notEmpty().withMessage('Last name is required');
const Email = body('email').notEmpty().withMessage('Email is required').isEmail().withMessage('Email not valid');
const Age = body('age').notEmpty().withMessage('Age is required');
const Password = body('password').notEmpty().withMessage('Password is required').isLength({ min: 8 }).withMessage('Password must be at least 8 characters');
const Type_oftheuser = body('typeofuser').notEmpty().withMessage('Type of the user is required');

const createCaregiverValidation = [
    First_name,
    Last_name,
    Email,
    Age,
    Password,
    Type_oftheuser
];

module.exports = {
    createCaregiverValidation
};
