const AWS = require("aws-sdk");
AWS.config.update({ region: 'us-west-2' });
const moment = require("moment");

const { google } = require('googleapis');
const { stringify } = require('querystring');
const OAuth2 = google.auth.OAuth2;





exports.send_email = async (req, res) => {
    try {
        const toAddress = [req.body.to];
        const response = await send_mail(toAddress, req.body.subject, req.body.message, req.body.from);
        if (!response) {
            return res.send({ status: "ERROR", message: "Mail Not Sent!", response })
        }
        return res.send({ status: "SUCCESS", message: "Mail sent!", response })
    } catch (error) {
        return res.send({ status: "ERROR", error });
    }
}

const send_mail = async (to, subject, message, from = null) => {
    try {
        const sendFrom = from != null ? from : "info@juristally.com";
        const SESConfig = {
            region: 'us-east-2',
            apiVersion: '2012-10-17',
            accessKeyId: process.env.AMAZONACCESSKEYID,
            secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
        };

        // Create email params
        const email_params = {
            Destination: {
                ToAddresses: [to]
            },
            Message: {
                Body: {
                    Html: {
                        Charset: "UTF-8",
                        Data: message
                    },
                    // Text: {
                    //     Charset: "UTF-8",
                    //     Data: messagess
                    // }
                },
                Subject: {
                    Charset: 'UTF-8',
                    Data: subject
                }
            },
            Source: sendFrom,
        };
        // console.log("request:  " + req);
        await new AWS.SES(SESConfig).sendEmail(email_params).promise();
        // Handle promise's fulfilled/rejected states
        return true;
    } catch (error) {
        console.log(error);
        return false;
    }
}



exports.send_mails = async (to, subject, message, from = null) => {
    try {
        const sendFrom = from != null ? from : "info@juristally.com";
        const SESConfig = {
            region: 'us-east-2',
            apiVersion: '2012-10-17',
            accessKeyId: process.env.AMAZONACCESSKEYID,
            secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
        };
        // Create email params
        const email_params = {
            Destination: {
                ToAddresses: [to]
            },
            Message: {
                Body: {
                    Html: {
                        Charset: "UTF-8",
                        Data: message
                    },
                    // Text: {
                    //     Charset: "UTF-8",
                    //     Data: message
                    // }
                },
                Subject: {
                    Charset: 'UTF-8',
                    Data: subject
                }
            },
            Source: sendFrom,
        };
        // console.log("request:  " + req);
        await new AWS.SES(SESConfig).sendEmail(email_params).promise();
        return true;
    } catch (error) {
        console.log(error);
        return false;
    }
}

















// const oauth2Client = new OAuth2(
//     process.env.GCLIENT_ID,
//     process.env.GCLIENT_SECRET,
//     "https://developers.google.com/oauthplayground"
// )

// oauth2Client.setCredentials({
//     refresh_token: process.env.REFRESH_TOKEN
// });
// const accessToken = oauth2Client.getAccessToken();

// const smtpTransport = nodemailer.createTransport({
//     service: 'gmail',
//     auth: {
//         type: 'OAuth2',
//         user: 'info@juristally.com',
//         clientId: process.env.GCLIENT_ID,
//         clientSecret: process.env.GCLIENT_SECRET,
//         refreshToken: process.env.REFRESH_TOKEN,
//         accessToken: accessToken
//     }
// });

// exports.send_mail = (recipients, subject, message) => {
//     const mailOptions = {
//         from: 'info@juristally.com',
//         to: recipients,
//         subject: subject,
//         generateTextFromHTMl: true,
//         html: message
//     };

//     smtpTransport.sendMail(mailOptions, (error, response) => {
//         error ? console.log(error) : console.log(response);
//         smtpTransport.close();
//     })
// }