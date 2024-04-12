const mongoose = require("mongoose");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const _ = require("lodash");
const moment = require("moment")
const refGenerator = require("voucher-code-generator");

const User = require("../../Models/Auth");
const OTP = require("../../Models/Auth/otp");
const PasswordToken = require("../../Models/Auth/password_token")
const { send_otp } = require("../../Utilities/send_otp");
const { send_sms } = require("../../Utilities/send_sms");
const { send_mails } = require("../../Utilities/send_mail");


exports.sign_up = async (req, res) => {
    try {
        const check_user = await User.findOne({ $or: [{ email: req.body.email }, { contact_number: req.body.contact_number }] });
        if (!_.isEmpty(check_user)) {
            return res.send({ status: "EXISTS", message: "You are already registred with us" })
        }
        const salt = genRandomString(32);
        const ref_code = getReferralCode();
        const hashed_password = sha512(req.body.password, salt)
        const user = new User({
            _id: new mongoose.Types.ObjectId(),
            full_name: req.body.full_name,
            email: req.body.email,
            type: req.body.type,
            contact_number: req.body.contact_number,
            accept_terms: req.body.accept_terms,
            salt_value: salt,
            password: hashed_password, //password should be salt encrypted
            sign_in_method: req.body.sign_in_method,
            referral_code: ref_code
        });
        let response = await user.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        response = JSON.parse(JSON.stringify(response));
        const token = jwt.sign({ salt: response.salt_value, user_id: response._id }, process.env.SECRET_KEY);
        response.access_token = token;
        // const finalResponse = await send_otp(response)
        return res.send({ status: "SUCCESS", response: response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.sign_in = async (req, res) => {
    try {
        const email = req.body.email;
        const phone = req.body.contact_number;

        const check_user = email === null ? await User.findOne({ contact_number: phone }) : await User.findOne({ email: email });
        if (_.isEmpty(check_user)) {
            return res.send({ status: "NOT_FOUND", message: "User is not registered" });
        }
        const hashed_password = sha512(req.body.password, check_user.salt_value);
        let response = email === null ? await User.findOne({ $and: [{ password: hashed_password }, { contact_number: phone }] }) : await User.findOne({ $and: [{ password: hashed_password }, { email: email }] });
        if (_.isEmpty(response)) {
            return res.send({ status: "INVALID", message: "User credentials are not correct" });
        }
        response = JSON.parse(JSON.stringify(response));
        const token = jwt.sign({ salt: response.salt_value, user_id: response._id }, process.env.SECRET_KEY);
        response.access_token = token;
        // if (!response.contact_verified) {
        //     response = await send_otp(response);
        // }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.signin_with_social_media = async (req, res) => {
    try {
        const salt = genRandomString(32);
        const checkmethod = await User.findOne({ email: req.body.email });
        if (!_.isEmpty(checkmethod) && checkmethod.sign_in_method === 'password') {
            return res.send({ status: "ERROR", message: "User credentials are not correct" });
        }
        let response = await User.findOne({ $and: [{ sm_uid: req.body.sm_uid }, { email: req.body.email }] });
        if (_.isEmpty(response)) {
            const ref_code = getReferralCode();
            const user = new User({
                _id: new mongoose.Types.ObjectId(),
                sm_uid: req.body.sm_uid,
                full_name: req.body.name,
                email: req.body.email,
                type: req.body.type,
                profile_image: req.body.profile_image,
                contact_number: req.body.contact_number,
                accept_terms: req.body.accept_terms,
                sign_in_method: req.body.sign_in_method,
                salt_value: salt,
                referral_code: ref_code
            });
            response = await user.save();
        }
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        response = JSON.parse(JSON.stringify(response));
        const token = jwt.sign({ salt: response.salt_value, user_id: response._id }, process.env.SECRET_KEY);
        response.access_token = token;
        // const finalResponse = await send_otp(response)
        return res.send({ status: "SUCCESS", response: response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }

}


exports.verify_otp = async (req, res) => {
    try {
        const data = [{ _id: req.body.reg_id }, { code: req.body.code }, { user: req.body.user_id }]
        const otp = await OTP.findOne({ $and: data });
        if (_.isEmpty(otp)) {
            return res.send({ status: "ERROR", message: 'Provided credentials are wrong!' });
        }
        const response = await User.findByIdAndUpdate({ _id: req.body.user_id }, { $set: { contact_verified: true } }, { new: true }).select(" _id designation contact_verified contact_number email full_name type");
        const { email, phone, full_name } = response;
        const welcome_sms_text = welcome_sms(full_name);
        const welcome_email_message = welcome_email(full_name);
        const subject = "Welcome To JuristAlly";
        await send_mails(email, subject, welcome_email_message);
        send_sms(phone, welcome_sms_text);
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.resend_otp = async () => {
    try {

    } catch (error) {
        return res.send({ status: "ERROR", message: "OTP can not be sent!" });
    }
}

exports.reset_password = async (req, res) => {
    try {
        const mailPhone = req.body.email;
        const isItEmail = req.body.isEOrC;
        const token = req.body.token;
        const password = req.body.password;
        const checkToken = await PasswordToken.findOne({ $and: [{ token: token }, { mailphone: mailPhone }] });
        if (_.isEmpty(checkToken)) {
            return res.send({ status: "ERROR", message: 'Password can not be updated!' });
        }
        const checkUser = isItEmail ? await User.findOne({ email: mailPhone }) : await User.findOne({ contact_number: mailPhone });
        if (_.isEmpty(checkUser)) {
            return res.send({ status: "ERROR", message: "User does not exists" });
        }
        const salt = genRandomString(32);
        const hashed_password = sha512(password, salt);
        const data = {
            password: hashed_password,
            salt_value: salt
        }
        const response = await User.findByIdAndUpdate({ _id: checkUser._id }, { $set: data });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Password can not be updated!" });
        }
        await PasswordToken.findByIdAndDelete({ _id: checkToken._id });
        return res.send({ status: "SUCCESS", message: "Password is updated successfully, Try login now" });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Password can not be updated!" });
    }
}


exports.send_reset_password_link = async (req, res) => {
    try {
        const email = req.body.email;
        const phone = req.body.contact_number;
        const tempToken = genRandomString(32);
        const fakeString = genRandomString(64);
        const nextOneHr = addHours(1);
        const token = new PasswordToken({
            _id: new mongoose.Types.ObjectId(),
            token: tempToken,
            mailphone: email != null ? email : phone,
            expire_at: nextOneHr,
        })
        const response = await token.save();
        const link = `https://juristally.com/reset-password.html?new=${fakeString}&temp_address=${email}&temp_contact=${phone}&&temp_token=${tempToken}&old=${fakeString}&expires_at=${nextOneHr}`;
        if (email !== null) {
            const subject = "Link to reset password"
            const message = resetmail(link);
            await send_mails(email, subject, message);
        } else {
            const textmessage = linkText(link);
            send_sms(phone, textmessage);
        }
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Link not sent" });
        }
        return res.send({ status: "SUCCESS", message: `Link to reset password sent to your provided ${email != null ? "E-mail" : "phone number"}` });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}


const addHours = (h) => {
    const date = new Date();
    const currentTime = moment(date).add(h, "hours");
    return currentTime.toISOString();
}
const linkText = (link) => {
    return `We have received a request to reset your juristally password. Please click on the given link to reset password. click here: ${link}`;
}

const resetmail = (link) => {
    return `
    <!doctype html>
    <html lang="en-US">
    
    <head>
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
        <title>Reset Password</title>
        <meta name="description" content="Reset Password Email">
        <style type="text/css">
            a:hover {text-decoration: underline !important;}
        </style>
    </head>
    
    <body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #f2f3f8;" leftmargin="0">
        <!--100% body table-->
        <table cellspacing="0" border="0" cellpadding="0" width="100%" bgcolor="#f2f3f8"
            style="@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;">
            <tr>
                <td>
                    <table style="background-color: #f2f3f8; max-width:670px;  margin:0 auto;" width="100%" border="0"
                        align="center" cellpadding="0" cellspacing="0">
                        <tr>
                            <td style="height:80px;">&nbsp;</td>
                        </tr>
                        <tr>
                            <td style="text-align:center;">
                              <a href="https://juristally.com" title="logo" target="_blank">
                                <img width="60" src="https://juristally.com/img/JuristAlly_logo.png" title="logo" alt="logo">
                              </a>
                            </td>
                        </tr>
                        <tr>
                            <td style="height:20px;">&nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"
                                    style="max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);">
                                    <tr>
                                        <td style="height:40px;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:0 35px;">
                                            <h1 style="color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;">You have
                                                requested to reset your password</h1>
                                            <span
                                                style="display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;"></span>
                                            <p style="color:#455056; font-size:15px;line-height:24px; margin:0;">
                                                We cannot simply send you your old password. A unique link to reset your
                                                password has been generated for you. To reset your password, click the
                                                following link and follow the instructions.
                                            </p>
                                            <a href="${link}"
                                                style="background:#20e277;text-decoration:none !important; font-weight:500; margin-top:35px; color:#fff;text-transform:uppercase; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;">Reset
                                                Password</a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="height:40px;">&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        <tr>
                            <td style="height:20px;">&nbsp;</td>
                        </tr>
                        <tr>
                            <td style="text-align:center;">
                                <p style="font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;">&copy; <strong>www.juristally.com</strong></p>
                            </td>
                        </tr>
                        <tr>
                            <td style="height:80px;">&nbsp;</td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
    </html>`;
}


const genRandomString = (length) => {
    return crypto.randomBytes(Math.ceil(length / 2))
        .toString('hex') /** convert to hexadecimal format */
        .slice(0, length);   /** return required number of characters */
};

const sha512 = (password, salt) => {
    var hash = crypto.createHmac('sha512', salt); /** Hashing algorithm sha512 */
    hash.update(password);
    var value = hash.digest('hex');
    return value;
};

const getReferralCode = () => {
    return refGenerator.generate({ length: Math.floor(Math.random() * (12 - 6) + 6), count: 1, charset: refGenerator.charset('alphanumeric') })[0];
}

const welcome_email = (usernmae) => {
    return `<div> <p>Dear ${_.upperFirst(usernmae)},</p>

    <p>Thanks for signing up for JuristAlly!</p>
    <br/>
    <p>On behalf of <b>JuristAlly</b>, I would like to take this opportunity to welcome you as our new User. We are thrilled to have you and many many thanks for choosing and believing in <b>JuristAlly</b>.</p>
    <p>At <b>JuristAlly</b> we pride ourself on offering our User responsive, competent and excellent services. Our Users are the most important part of our business and we work tirelessly to ensure your complete satisfaction, now and for as long as you will be our User.</p>       
    <p>We will be happy to answer you or help you at any time of moment. For any queries or interaction kindly reach us at <a href="mailto:info@juristally.com">info@juristally.com</a>.</p>.
    <br /> 
    <p>Thank you again for believing in <b>JuristAlly!!!</b></p>        
    
    <br/>
    <p>Warm Regards,</p>
    <p>Aakashdeep</p>
   <p>Founder & CEO</p>
   <p>JursitAlly</p></div>`;
}

const welcome_sms = (username) => {
    return `
    Hello ${_.upperFirst(username)}, We are delighted that you signed up. We believe that each member contributes directly to the JuristAlly growth and success, and we hope you will take pride in being a member of the JuristAlly.

    Team,
    JuristAlly
    `;
}