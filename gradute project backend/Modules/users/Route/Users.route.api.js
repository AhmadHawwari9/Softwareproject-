const express = require('express');
const { createUsersValidation } = require("../Validation/Users.validation");
const { createUsersUsingPost } = require("../Controller/users.controller");

const { createUsersValidationLogin } = require("../Validation/userslogin_validation");
const { createUsersUsingPostLogin } = require("../Controller/userslogin.controller");

const { sendCode, verifyCode } = require("../Controller/emailandcode.controller");
const { validateEmail, validateCode, validateNewPassword } = require("../Validation/Emailandcode.Validation");
const { resetPassword } = require('../Controller/emailandcode.controller');

const jwt = require("jsonwebtoken");
const { authonitication } = require('../../../middlware/logger.authonitication');
const { homepagecontroller } = require("../Controller/homepage");
const { createUsersUsingGoogleSignIn } = require("../Controller/SignInwithGoogle.controller");

const { sendMessage, getMessagesWithUser, getAllConversations } = require('../Controller/Message.Controller');
const { messageValidation } = require('../Validation/Message.Validation');

const router = express.Router();

router.post('/api/users', createUsersValidation, createUsersUsingPost); // Sign up
router.post('/api/Login', createUsersValidationLogin, createUsersUsingPostLogin);
router.post('/api/ForgetPassword', validateEmail, sendCode);
router.post('/api/ForgetPasswword/verifycode', validateCode, verifyCode);
router.post('/api/ForgetPassword/verifycode/Newpassword', validateNewPassword, resetPassword);
router.get('/api/homepage', authonitication, homepagecontroller);
router.post('/api/SignInwithGoogle', createUsersUsingGoogleSignIn);

// Chat routes
router.post('/chat/send', authonitication, messageValidation, sendMessage);
router.get('/chat/receive/:otherUserId', authonitication, getMessagesWithUser); // Get messages with specific user
router.get('/chat/conversations', authonitication, getAllConversations); // Get all conversations

module.exports = router;
