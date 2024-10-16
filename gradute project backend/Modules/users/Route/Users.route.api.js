const express = require('express');
const  {createUsersValidation} =require("../Validation/Users.validation")
const {createUsersUsingPost}=require("../Controller/users.controller")

const {createUsersValidationLogin}=require("../Validation/userslogin_validation")
const {createUsersUsingPostLogin} =require("../Controller/userslogin.controller");

const { sendCode, verifyCode }=require("../Controller/emailandcode.controller");
const { validateEmail, validateCode }=require("../Validation/Emailandcode.Validation");
const {validateNewPassword} =require ('../Validation/Emailandcode.Validation');
const {resetPassword}=require('../Controller/emailandcode.controller');


const router=express.Router();


router.post('/api/users',createUsersValidation,createUsersUsingPost);//sign up
router.post('/api/Login',createUsersValidationLogin,createUsersUsingPostLogin);
router.post('/api/ForgetPassword',validateEmail,sendCode);
router.post('/api/ForgetPasswword/verifycode',validateCode,verifyCode);
router.post('/api/ForgetPassword/verifycode/Newpassword', validateNewPassword, resetPassword);

module.exports=router;