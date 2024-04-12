const mongoose = require("mongoose");
const _ = require("lodash");
const { json } = require("body-parser");

const UserChatGroup = require("./my-chat-group");
const ChatMessages = require("./chat-message-model");
const User = require("../Models/Auth")
const { notification_trigger } = require("../Controllers/Notifications");

exports.add_user_list = async (from, to) => {
    try {
        const forFrom = await add_user(from, to);
        const forTo = await add_user(to, from);
        console.log("from: ");
        console.log(forFrom);
        console.log("to: ");
        console.log(forTo);
        return;
    } catch (error) {
        return { status: 'ERROR' };
    }
}

const add_user = async (from, to) => {
    try {
        const userList = new UserChatGroup({
            _id: new mongoose.Types.ObjectId(),
            user_id: from,
            users: [to]
        });
        const checkIfExists = await UserChatGroup.findOne({ user_id: from });
        if (_.isEmpty(checkIfExists)) {
            await userList.save();
            return { status: "CREATED" };
        }
        const checkUser = await UserChatGroup.find({ $and: [{ user_id: from }, { users: to }] }).exec();
        if (!_.isEmpty(checkUser)) {
            return { status: 'EXISTS' };
        }
        await UserChatGroup.findOneAndUpdate({ user_id: from }, { $push: { users: to } });
        return { status: 'ADDED' };
    } catch (error) {
        return { status: 'ERROR' };
    }
}

exports.fetch_chatlist = async (userId) => {
    try {
        const response = await UserChatGroup.findOne({ user_id: userId }).populate("users", '_id full_name contact_number profile_image designation type');
        if (_.isEmpty(response)) {
            return json({ status: "ERROR", message: 'Chat list not found' });
        }
        return response;
    } catch (error) {
        return json({ status: 'ERROR', message: error.message });
    }
}

exports.save_messages = async (chat_data) => {
    try {
        const messageObj = {
            message: chat_data.message,
            media: chat_data.media,
            from: chat_data.from,
            to: chat_data.to,
            timestamp: new Date(),
        };

        const participant1Obj = {
            user: chat_data.to
        };

        const participant2Obj = {
            user: chat_data.from
        }

        const chatObject = new ChatMessages({
            _id: new mongoose.Types.ObjectId(),
            messages: messageObj,
            participants: [participant1Obj, participant2Obj]
        });
        const usr = await User.findById({ _id: chat_data.to }).select("_id full_name");
        const checkExists = await ChatMessages.findOne({ "participants.user": { $all: [participant1Obj.user, participant2Obj.user] } })
        const title = `Message from ${usr.full_name}`;
        await notification_trigger(chat_data.to, title, messageObj.message, true);
        if (_.isEmpty(checkExists)) {
            await chatObject.save();
            return json({ status: "THREAD-STARTED" })
        }
        await ChatMessages.findOneAndUpdate({ "participants.user": { $all: [participant1Obj.user, participant2Obj.user] } }, { $push: { messages: messageObj } })
        return json({ status: "UPDATED" });
    } catch (error) {
        return json({ status: "ERROR", message: error.message });
    }
}

exports.fetch_all_message = async (from, to) => {
    try {
        const response = await ChatMessages.findOne({ "participants.user": { $all: [from, to] } }).exec();
        if (_.isEmpty(response)) {
            return json({ status: "ERROR", message: 'Not found!' });
        }
        return response;
    } catch (error) {
        return json({ status: 'ERROR', message: error.message });
    }
}

exports.notify_on_message = async () => {

}