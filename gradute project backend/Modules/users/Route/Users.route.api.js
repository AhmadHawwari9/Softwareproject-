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

const {markMessageAsRead}=require('../Controller/Message.Controller');
const { sendMessage, getMessagesWithUser, getAllConversations } = require('../Controller/Message.Controller');
const { messageValidation } = require('../Validation/Message.Validation');
const userController = require('../Controller/imageshow.controller');
const {uploadPdf}=require('../Controller/MedicalReportpdf.controller');
const {getUserFiles}=require('../Controller/MedicalReportpdf.controller');
const {checkReport}=require('../Controller/medicalTests.controller');
const {deleteUserFile,getFilesByUserId}=require('../Controller/MedicalReportpdf.controller');
const {getUserProfile}=require('../Controller/Profile.controller');
const {updateUserBio}=require('../Controller/Profile.controller');
const {updateUserage,updateImageForUser}=require('../Controller/Profile.controller');
const{getSchedule,updateSchedule,deleteSchedule,addSchedule}=require('../Controller/scheduleforcaregiver.Controller');
const {getCareRecipients}=require('../Controller/Tablecarerecipientlist.controller');
const {getReportsByUserId}=require('../Controller/History.controller');
const {getUsers,deleteUser} =require('../Controller/Operationsonusersfortheadmin.controller');
const{createCaregiverValidation}=require('../Validation/caregiverRequestToTheAdmin.validation');
const{createCaregiverUsingPost,getCaregiver,moveCaregiverToUser,deleteCaregiverRequest}=require('../Controller/caregiverRequestToTheAdmin.controller');
const {updateEmailController,changePassword,deletemyaccount}=require('../Controller/Settings.controller');
const {getUsersfromsearch,getUserById}=require('../Controller/search.controller');
const{getScheduleByDate}=require('../Controller/scheduleforcaregiver.Controller');
const router = express.Router();

const uploade = require('../../fileMannager/helper/multerobj');
router.post('/api/users',uploade.single("photo"),createUsersValidation, createUsersUsingPost); // Sign up
router.post('/api/Login', createUsersValidationLogin, createUsersUsingPostLogin);
router.post('/api/ForgetPassword', validateEmail, sendCode);
router.post('/api/ForgetPasswword/verifycode', validateCode, verifyCode);
router.post('/api/ForgetPassword/verifycode/Newpassword', validateNewPassword, resetPassword);
router.get('/api/homepage', authonitication, homepagecontroller);

router.post('/api/SignInwithGoogle', createUsersUsingGoogleSignIn);

// Chat routes
router.post('/chat/send', uploade.fields([{ name: 'audio', maxCount: 1 }, { name: 'photo', maxCount: 1 }]),authonitication,messageValidation,sendMessage);

router.get('/chat/receive/:otherUserId', authonitication, getMessagesWithUser); // Get messages with specific user
router.get('/chat/conversations', authonitication, getAllConversations); // Get all conversations
router.get('/user/image/:email', userController.getUserImagePath);


router.post('/chat/conversations/:otherUserId',authonitication, markMessageAsRead);


router.post('/upload', authonitication,uploade.single('file'), uploadPdf);

router.get('/user/files',authonitication, getUserFiles);

router.post('/check', checkReport);
router.delete('/user/files/:id', authonitication, deleteUserFile);

router.get('/profile', authonitication, getUserProfile);
router.put('/update-bio', authonitication, updateUserBio);
router.put('/update-age', authonitication, updateUserage);
router.post('/update-image',uploade.single('photo'),authonitication, updateImageForUser);

router.get('/ScheduleforCaregiver', authonitication, getSchedule);
router.get('/ScheduleForCaregiverByDate/:date', authonitication, getScheduleByDate);


router.put('/updateSchedule/:scedual_id',authonitication ,updateSchedule);

router.delete('/deleteSchedule/:scedual_id', authonitication, deleteSchedule);

router.post('/addSchedule', authonitication, addSchedule);

router.get('/getCareRecipients', authonitication, getCareRecipients);

router.get('/user/files/:id', getFilesByUserId);

router.get('/History/:user_id', getReportsByUserId);

router.get('/usersoperationsforadmin', authonitication, getUsers);

router.delete('/deleteUser/:id',deleteUser);

router.post('/caregiverRequestToTheAdmin', uploade.fields([{ name: 'photo', maxCount: 1 }, { name: 'file', maxCount: 1 }]), createCaregiverValidation, createCaregiverUsingPost);
router.get('/caregiverRequestToTheAdminDisplay',getCaregiver);

router.delete('/movecaregivertouserstable/:requestId', moveCaregiverToUser);
router.delete('/deletecaregiver/:requestId',deleteCaregiverRequest);


//for the settings
router.put('/updateemail', authonitication, updateEmailController);
router.post('/changepassword',authonitication , changePassword);
router.delete('/deleteuser',authonitication, deletemyaccount);

//search
router.get('/getUsersforsearch', getUsersfromsearch);
router.get('/getUsersforsearch/:id', getUserById);

module.exports = router;
