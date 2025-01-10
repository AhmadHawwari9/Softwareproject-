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

const {markMessageAsRead,fetchUnreadMessageCount}=require('../Controller/Message.Controller');
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
const{getSchedule,updateSchedule,deleteSchedule,addSchedule,getScheduleByDateForUser}=require('../Controller/scheduleforcaregiver.Controller');
const {getCareRecipients}=require('../Controller/Tablecarerecipientlist.controller');
const {getReportsByUserId,getUserReports}=require('../Controller/History.controller');
const {getUsers,deleteUser} =require('../Controller/Operationsonusersfortheadmin.controller');
const{createCaregiverValidation}=require('../Validation/caregiverRequestToTheAdmin.validation');
const{createCaregiverUsingPost,getCaregiver,moveCaregiverToUser,deleteCaregiverRequest,getHospital}=require('../Controller/caregiverRequestToTheAdmin.controller');
const {updateEmailController,changePassword,deletemyaccount}=require('../Controller/Settings.controller');
const {getUsersfromsearch,getUserById}=require('../Controller/search.controller');
const{getScheduleByDate,addScheduleById}=require('../Controller/scheduleforcaregiver.Controller');
const articleController = require('../Controller/articals.controller');
const {sendFollowRequest,getUserNotifications,fetchUserNotifications,deleteFollowRequest,approveFollowRequest,
    removeFollowRequest1,fetchCareGiversForRecipient,sendUnfollowRequest,
    deleteUnfollowRequest,getUnfollowNotifications,deleteNotification,
    handleNotificationAndUnfollowRequestDeletion,
    handleNotificationAndUnfollowRequestDeletionforcarerecipant,fetchNotificationCount,
    markNotificationsAsRead}=require('../Controller/follow.controller');

    const {setDoctorAvailability,getDoctorAvailability,fetchDoctorAvailability}=require('../Controller/doctorAvailability.Controller');

    const{modifySchedule,removeSchedule,fetchCaregiverSchedule}=require('../Controller/scheduleforcaregiver.Controller');
    const {getMedications,getAllMedicationsForPatient,createNewMedication,
        getMedicationsForPatientById,
        getUserEmailByToken,
        deleteMedicationById,
        fetchMedicationsReminder
    }=require('../Controller/medicine.controller');


    const{getAllHospitals,getHospitalByUserId,updateHospital}=require('../Controller/hospitals.controller');
    
const router = express.Router();
const {sendCareRecipientNotifications}=require('../Controller/Emergencybutton.controller');

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
router.get('/unread-message-count', authonitication, fetchUnreadMessageCount);


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
router.get('/user-history', authonitication, getUserReports);

router.get('/usersoperationsforadmin', authonitication, getUsers);

router.delete('/deleteUser/:id',deleteUser);

router.post('/caregiverRequestToTheAdmin', uploade.fields([{ name: 'photo', maxCount: 1 }, { name: 'file', maxCount: 1 }]), createCaregiverValidation, createCaregiverUsingPost);
router.get('/caregiverRequestToTheAdminDisplay',getCaregiver);
router.get('/hospitalRequestToTheAdminDisplay', getHospital);

router.delete('/movecaregivertouserstable/:requestId', moveCaregiverToUser);
router.delete('/deletecaregiver/:requestId',deleteCaregiverRequest);


//for the settings
router.put('/updateemail', authonitication, updateEmailController);
router.post('/changepassword',authonitication , changePassword);
router.delete('/deleteuser',authonitication, deletemyaccount);

//search
router.get('/getUsersforsearch', authonitication,getUsersfromsearch);
router.get('/getUsersforsearch/:id', getUserById);

router.get('/articles', articleController.getArticles);
router.delete('/articles/:id', articleController.deleteArticle);
router.post('/addnewArticle', uploade.single('photo'),articleController.addArticle);


//follow
router.post('/follow', authonitication, sendFollowRequest);
router.get('/notifications',authonitication , getUserNotifications);
router.get('/notificationssender', authonitication, fetchUserNotifications);
router.delete('/Deletefollowrequest/:receiverId',authonitication , deleteFollowRequest);
router.post('/approveFollowRequest', authonitication, approveFollowRequest);
router.delete('/deleteFollowRequest', authonitication, removeFollowRequest1);
router.get('/caregivers', authonitication, fetchCareGiversForRecipient);
router.post('/unfollow', authonitication, sendUnfollowRequest);
router.delete('/DeleteUnfollowRequest/:receiverId', authonitication, deleteUnfollowRequest);
router.get('/getUnfollowNotifications', authonitication, getUnfollowNotifications);
router.delete('/deleteNotificationunfollowrequest/:senderId',authonitication , deleteNotification);
router.delete('/deleteNotificationAndUnfollowAccept/:senderId', authonitication, handleNotificationAndUnfollowRequestDeletion);
router.delete('/deleteNotificationAndUnfollowAcceptforcarerecipant/:senderId', authonitication, handleNotificationAndUnfollowRequestDeletionforcarerecipant);
router.get('/notification-count', authonitication, fetchNotificationCount);
router.put('/mark-notifications-read', authonitication, markNotificationsAsRead);

router.post('/setAvailability', authonitication, setDoctorAvailability);
router.get('/getAvailability', authonitication, getDoctorAvailability);
router.get('/getScheduleByDateForUser/:userId/:date', getScheduleByDateForUser);
router.put('/modifySchedule/:userId/:scheduleId', modifySchedule);
router.delete('/removeSchedule/:userId/:scheduleId', removeSchedule);

router.get('/caregiverSchedule/:userId', fetchCaregiverSchedule);
router.get('/availability/:id', fetchDoctorAvailability);
router.post('/schedulefromthecarerecipant/:id', addScheduleById);
router.get('/getMedications/:doctorId', authonitication, getMedications);
router.get('/medications', authonitication, getAllMedicationsForPatient);
router.post('/add-medication', authonitication, createNewMedication);
router.get('/medications/:patientId', getMedicationsForPatientById);
router.get('/user/email', authonitication, getUserEmailByToken); 
router.delete('/medication/:id', deleteMedicationById);
router.get('/medication-reminder', authonitication, fetchMedicationsReminder);

router.get('/hospitals', getAllHospitals);
router.get('/hospitalbyidfromauthnitication',authonitication, getHospitalByUserId);
router.post('/updateHospital', uploade.single('photo'),authonitication, updateHospital);

//Emergency button
router.get('/sendNotifications', authonitication, sendCareRecipientNotifications);


module.exports = router;
