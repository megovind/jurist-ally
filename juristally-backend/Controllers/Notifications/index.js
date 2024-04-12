const mongoose = require('mongoose');
const _ = require('lodash');
const fcmAdmin = require("firebase-admin");
const credetials = require("../../assets/new-juristally-firebase-adminsdk-rizre-e7a31be82e.json");
fcmAdmin.initializeApp({
    credential: fcmAdmin.credential.cert(credetials)
})

const fcm = fcmAdmin.messaging();

const Notifications = require('../../Models/Notifications');
const NotificationsToken = require("../../Models/Notifications/reg-tokens");


exports.update_registration_token = async (req, res) => {
    try {
        let response;
        const isExists = await NotificationsToken.findOne({ $and: [{ user: req.body.user }, { platform: req.body.platform }] });
        if (!_.isEmpty(isExists)) {
            response = await NotificationsToken.findOneAndUpdate({ $and: [{ user: req.body.user }, { platform: req.body.platform }] }, { $set: { token: req.body.token, updated_at: new Date() } }, { new: true });
        } else {
            const token = new NotificationsToken({
                _id: new mongoose.Types.ObjectId(),
                user: req.body.user,
                platform: req.body.platform,
                token: req.body.token,
            })
            response = await token.save();
        }
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.send = async (req, res) => {
    const response = await send_notification(req.body.uid, req.body.title, req.body.message);
    return res.send({ response });
}

exports.notification_trigger = async (uid, title, message, isChat = false) => {
    const response = await send_notification(uid, title, message, isChat);
    return response;
}

const send_notification = async (uid, title, message, isChat) => {
    try {
        const notification = new Notifications({
            _id: mongoose.Types.ObjectId(),
            user: uid,
            title: title,
            notification: message
        });
        const fetchTokens = await NotificationsToken.find({ user: uid });
        const response = isChat ? { status: "SUCCESS", message: 'From chat' } : await notification.save();
        fetchTokens.map(async d => {
            await trigger_notification(d.token, title, message);
        })
        return response;
    } catch (error) {
        return { status: 'ERROR' };
    }
}


const trigger_notification = async (token, title, body) => {
    const payload = {
        notification: {
            title: title,
            body: body,
            icon: "icon-logo",
            clickAction: "FLUTTER_NOTIFICATIOn_CLICK"
        }
    }
    const options = {
        priority: "high",
        timeToLive: 60 * 60 * 24
    }

    const response = await fcm.sendToDevice(token, payload, options);
    return response;
}

exports.fetch_notifications = async (req, res) => {
    try {
        const uid = req.params.id;
        const response = await Notifications.find({ user: uid }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'Notifications not found!' });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}