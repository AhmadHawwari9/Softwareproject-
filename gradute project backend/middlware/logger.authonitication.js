const jwt = require("jsonwebtoken");

const authonitication=(req,res,next)=>{
    const token= req.headers.token;

    if (token){
        try{

            const user=jwt.verify(token,'Course');
            next();
        }catch(err){
            return res.status(401).json({
                message:'invalid token'
            });
        }
    }else{
        return res.status(401).json({
            message:'token is missed'
        });
    }
}

module.exports={
    authonitication
}