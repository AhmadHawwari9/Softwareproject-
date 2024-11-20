const { body,check,param,query } = require("express-validator");


const Email = body('email').notEmpty().withMessage('Email is required').isEmail().withMessage('Email not valid');
const Password = body('password').notEmpty().withMessage('Password is required').isLength({ min: 8 }).withMessage('Password must be at least 8 characters');

const createUsersValidationLogin =[
    Email,
    Password
]
  


module.exports={
    createUsersValidationLogin
}