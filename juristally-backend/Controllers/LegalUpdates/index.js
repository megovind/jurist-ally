const mongoose = require('mongoose');
const AWS = require("aws-sdk");
const _ = require('lodash');

const LegalUpdate = require("../../Models/LegalUpdates");
const User = require("../../Models/Auth");

const { send_sms } = require("../../Utilities/send_sms");
const { send_mails } = require("../../Utilities/send_mail")
const { notification_trigger } = require("../../Controllers/Notifications/index")


exports.add_legal_update = async (req, res) => {
    try {
        if (_.isEmpty(req.body.act_rule)) {
            return res.send({ status: "ERROR", message: "Please provide all the correct details!" })
        }
        const s3bucket = new AWS.S3({
            accessKeyId: process.env.AMAZONACCESSKEYID,
            secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
            Bucket: process.env.AMAZONS3BUCKETNAME
        });
        const file = req.file;
        const file_link = req.body.file_link;
        if (!_.isEmpty(file_link)) {
            const update = new LegalUpdate({
                _id: mongoose.Types.ObjectId(),
                act_rule: req.body.act_rule,
                file: file_link,
                passed_on: req.body.passed_on,
                lang: req.body.lang,
                reference: req.body.reference,
                reference_link: req.body.reference_link
            });
            const response = await update.save();
            return res.send({ status: "SUCCESS", response })
        }
        if (!_.isEmpty(file)) {
            const params = {
                Bucket: process.env.AMAZONS3BUCKETNAME,
                Key: new Date().toISOString() + "-" + file.originalname,
                Body: file.buffer,
                ContentType: file.mimetype,
                ACL: "public-read"
            }
            s3bucket.upload(params, async (error, data) => {
                if (error) {
                    return res.send({ status: "ERROR", message: error.message });
                }
                const update = new LegalUpdate({
                    _id: mongoose.Types.ObjectId(),
                    act_rule: req.body.act_rule,
                    file: data.Location,
                    passed_on: req.body.passed_on,
                    lang: req.body.lang,
                    reference: req.body.reference,
                    reference_link: req.body.reference_link
                });
                const response = await update.save();
                await alertUser(req.body);
                return res.send({ status: "SUCCESS", response: response });
            })
        } else {
            return res.send({ status: "ERROR", message: "File in empty" })
        }
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


const alertUser = async (data) => {
    const title = `Legal Update`;
    const subject = `Legal Update`;
    const smsNotifcation = data.act_rule;
    const mailText = emailText(data);
    const users = await User.find().select("_id full_name type designation email contact_number");
    //need to add filter to remove all the other users and students
    users.forEach(async usr => {
        // send_sms(usr.contact_number, smsNotifcation);
        // await send_mails(usr.email, subject, mailText);
        await notification_trigger(usr._id, title, smsNotifcation);
    });
}
const emailText = (data) => {
    return `<div>
    <p>Hi There,</p>
    <br />
    <p>New legal update just posted.</p> 
    <p>${data.act_rule} <a href="https://play.google.com/store/apps/details?id=com.jurist_ally&hl=en_IN" target="blank">read more</a></p>
    <br />
    <p>Team,</p>
    <p>JuristAlly</p>
    </div>`;
}


exports.fetch_legalupdates = async (req, res) => {
    try {
        const PAGE_SIZE = 20;
        const searchString = req.query.q;
        const pageNumber = req.query.page ? parseInt(req.query.page) : 1;
        const lang = req.query.lang ? req.query.lang : "en";
        const skip = (pageNumber - 1) * PAGE_SIZE;
        const data = searchString && searchString.length > 0 ? { $and: [{ act_rule: { $regex: new RegExp(searchString) } }, { lang: lang }] } : { lang: lang };
        const response = req.query.page ? await LegalUpdate.find(data).sort({ passed_on: -1 }).skip(skip).limit(PAGE_SIZE).exec() : await LegalUpdate.find({ lang: lang }).sort({ passed_on: -1 }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Updates not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}