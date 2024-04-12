const mongoose = require("mongoose");
const _ = require("lodash");

const User = require("../../Models/Auth");

exports.update_profile = async (req, res) => {
    try {
        const id = req.params.id;
        const data = {
            gender: req.body.gender,
            about: req.body.about,
            location: req.body.location,
            designation: req.body.designation,
            practice_area: req.body.practice_area,
            profile_image: req.body.profile_image,
        };
        const user = await User.findByIdAndUpdate({ _id: id }, { $set: data });
        if (_.isEmpty(user)) {
            return res.send({ status: "ERROR", message: "User not found" })
        }
        return res.send({ status: "SUCCESS", response: user });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_user_type = async (req, res) => {
    try {
        const user_id = req.params.id;
        const data = {
            type: req.body.type,
            id_card_number: req.body.id_number,
            id_card: req.body.id_card,
            company_id: req.body.company_id,
            company_id_card: req.body.company_id_card,
            registration_number: req.body.registration_number,
            registration_card: req.body.registration_card,
            bar_council_number: req.body.bar_council_number,
            bar_council_card: req.body.bar_council_card,
        };
        const response = await User.findByIdAndUpdate({ _id: user_id }, { $set: data }, { new: true });
        if (_.isEmpty(response)) {
            return res.send({ status: 'ERROR', message: 'Something went wrong!' });
        }
        return res.send({ status: 'SUCCESS', response: response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }

}

exports.update_user_profile = async (req, res) => {
    try {
        const user_id = req.params.id;
        const data = {
            full_name: req.body.full_name,
            type: req.body.type,
            id_card_number: req.body.id_number,
            id_card: req.body.id_card,
            company_id: req.body.company_id,
            company_id_card: req.body.company_id_card,
            registration_number: req.body.registration_number,
            registration_card: req.body.registration_card,
            bar_council_number: req.body.bar_council_number,
            bar_council_card: req.body.bar_council_card,
            gender: req.body.gender,
            about: req.body.about,
            location: req.body.location,
            designation: req.body.designation,
            practice_area: req.body.practice_area,
            profile_image: req.body.profile_image,
        };
        const response = await User.findByIdAndUpdate({ _id: user_id }, { $set: data }, { new: true });
        if (_.isEmpty(response)) {
            return res.send({ status: 'ERROR', message: 'User does not exists' });
        }
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" })
    }
}



exports.get_user_profile = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await User.findById({ _id: id })
            .populate('education')
            .populate('experience')
            .populate('practice_area')
            .populate("subscription");
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "User not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


exports.search_user = async (req, res) => {
    try {
        const query = req.params.query;
        const type = req.params.type;
        const response = await User.find().select("_id full_name designation type email contact_number profile_image").exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "User details not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_connection = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await User.findById({ _id: id }).populate("sent_follow_requests", '_id full_name designation').populate("follow_requests", '_id full_name designation').populate("followers", '_id full_name designation');
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "User not found" });
        }
        const users = await User.find().select("_id full_name designation type");
        const connections = [response, ...response.follow_requests, ...response.sent_follow_requests, ...response.followers];
        var resp = users.filter(n => connections.find(n1 => n._id === n1._id));
        return res.send({
            status: "SUCCESS",
            users: resp,
            requests: response.follow_requests,
            sent_requests: response.sent_follow_requests,
            followers: response.followers,
        });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message })
    }
}

exports.send_connection_Request = async (req, res) => {
    try {
        const senderId = req.params.sender_id;
        const recieverId = req.params.reciever_id;
        const reciever = await User.findById({ _id: recieverId }).select("_id full_name designation type");
        const senderResponse = await User.findByIdAndUpdate({ _id: senderId }, { $push: { sent_follow_requests: recieverId } }, { new: true });
        const recieverResponse = await User.findByIdAndUpdate({ _id: recieverId }, { $push: { follow_requests: senderId } }, { new: true });
        if (_.isEmpty(senderResponse) && _.isEmpty(recieverResponse)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", reciever: reciever });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


exports.accept_request = async (req, res) => {
    try {
        const userId = req.params.user_id;
        const requesterId = req.params.requester_id;
        const requester = await User.findById({ _id: requesterId }).select("_id full_name designation type");
        await User.findByIdAndUpdate({ _id: userId }, { $addToSet: { followers: requesterId } }, { new: true, multi: true });
        const acceptResponse = await User.findByIdAndUpdate({ _id: userId }, { $pull: { follow_requests: requesterId } }, { new: true, multi: true });
        await User.findByIdAndUpdate({ _id: requesterId }, { $addToSet: { followers: userId } }, { new: true, multi: true });
        const requestResponse = await User.findByIdAndUpdate({ _id: requesterId }, { $pull: { sent_follow_requests: userId } }, { new: true, multi: true });
        if (_.isEmpty(requestResponse) && _.isEmpty(acceptResponse)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        return res.send({ status: "SUCCESS", requester: requester });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.reject_request = async (req, res) => {
    try {
        const userId = req.params.user_id;
        const requesterId = req.params.requester_id;
        const rejetResponse = await User.findByIdAndUpdate({ _id: userId }, { $pull: { follow_requests: requesterId } }, { new: true });
        const senderResponse = await User.findByIdAndUpdate({ _id: requesterId }, { $pull: { sent_follow_requests: userId } }, { new: true });
        if (_.isEmpty(senderResponse) && _.isEmpty(rejetResponse)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        return res.send({ status: "SUCCESS", rejectResponse: rejetResponse.follow_requests, senderResponse: senderResponse.sent_follow_requests });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


