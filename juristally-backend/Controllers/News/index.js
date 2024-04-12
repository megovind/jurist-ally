const mongoose = require("mongoose");
const _ = require("lodash");

const News = require("../../Models/News");
const User = require("../../Models/Auth");

const { send_sms } = require("../../Utilities/send_sms");
const { send_mails } = require("../../Utilities/send_mail")
const { notification_trigger } = require("../../Controllers/Notifications/index")


exports.create_news = async (req, res) => {
    try {
        const news = new News({
            _id: mongoose.Types.ObjectId(),
            user: req.params.id,
            heading: req.body.heading,
            description: req.body.description,
            image: req.body.image,
            link: req.body.link,
        });
        const response = await news.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        await alertUser(req.body);
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

const alertUser = async (data) => {
    const title = `Legal News Alert: ${data.heading}`;
    const subject = `Legal News Alert: ${data.heading}`;
    const smsNotifcation = `${data.heading} read more https://play.google.com/store/apps/details?id=com.jurist_ally&hl=en_IN`;
    const mailText = emailText(data);
    const users = await User.find().select("_id full_name type designation email contact_number");
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
    <p>${data.description} <a href="https://play.google.com/store/apps/details?id=com.jurist_ally&hl=en_IN" target="blank">read more</a></p> 
    ${data.image != null || data.image != undefined ? `<p><img src=${data.image} alt="Image not found"/>` : `<span/>`}
    <br />
    <p>Team,</p>
    <p>JuristAlly</p>
    </div>`;
}

exports.fetch_news = async (req, res) => {
    try {
        const response = await News.find().exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'News not found!' });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}