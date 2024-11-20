const { body } = require('express-validator');

const messageValidation = [
    body('sender_id').notEmpty().withMessage('Sender ID is required'),
    body('receiver_id').notEmpty().withMessage('Receiver ID is required'),
    
];

module.exports = {
    messageValidation,
};
