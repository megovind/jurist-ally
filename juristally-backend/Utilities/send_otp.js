const mongoose = require('mongoose');
const http = require('https');
const _ = require('lodash');
const moment = require('moment');
// const qs = require('querystring');

const OTP = require('../Models/Auth/otp');
const { send_mails } = require("../Utilities/send_mail")

const four_digit_code = () => {
    return Math.floor(1000 + Math.random() * 9000);
}

exports.send_otp = async (data) => {
    const otp = four_digit_code();
    const options = {
        method: 'GET',
        hostname: "api.msg91.com",
        port: null,
        path: `/api/v5/otp?authkey=${process.env.MSG_AUTHKEY}&template_id=${process.env.MSG_TEMPLATE_ID}&otp_length=4&otp_expiry=1&otp=${otp}&mobile=${'91' + data.contact_number}`,
        headers: {
            "content-type": "application/json"
        }
    }
    if (process.env.NODE_ENV === 'production') {
        const message = mailOTPMessage(otp);
        await send_mails(data.email, 'JuristAlly verification code', message);
        let req = http.request(options, function (res) {
            let chunks = [];
            res.on('data', function (chunk) {
                chunks.push(chunk);
            })
            res.on('end', function () {
                const body = Buffer.concat(chunks);
            });
        });
        req.end();
    }
    const Otp = new OTP({
        _id: mongoose.Types.ObjectId(),
        user: data._id,
        code: otp,
        phone: data.contact_number,
        type: data.type,
        expires_at: addMinutes(30)
    });
    const otpResp = await Otp.save();
    let response = JSON.parse(JSON.stringify(data))
    response.reg_id = otpResp._id;
    return response;
}

const mailOTPMessage = (otp) => {
    return `<div> 
<p>Hi There,</p>
<p>${otp} is your JURISTALLY One Time Password(OTP). Do not share this code with anyone else.</p>
<br/>
<p>Juristally</p>
</div>`;
}

const addMinutes = (t) => {
    const date = new Date();
    const currentTime = moment(date).add(t, "minutes");
    return currentTime.toISOString();
}