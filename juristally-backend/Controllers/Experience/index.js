const mongoose = require("mongoose");
const _ = require("lodash");

const Experience = require("../../Models/Experience");
const User = require("../../Models/Auth");

exports.add_experience = async (req, res) => {
    try {
        const id = req.params.id;
        const experience = new Experience({
            _id: mongoose.Types.ObjectId(),
            company_name: req.body.company,
            designation: req.body.designation,
            start_date: req.body.start_date,
            end_date: req.body.end_date,
            is_present: req.body.is_present

        });
        const response = await experience.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        await User.findByIdAndUpdate({ _id: id }, { $push: { experience: response._id } });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_experience = async (req, res) => {
    try {
        const id = req.params.id;
        const data = {
            company_name: req.body.company,
            designation: req.body.designation,
            start_date: req.body.start_date,
            end_date: req.body.end_date,
            is_present: req.body.is_present,
        };
        const response = await Experience.findByIdAndUpdate({ _id: id }, { $set: data }, { new: true });
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Record is not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.delete_experience = async (req, res) => {
    try {
        const id = req.params.id;
        const userId = req.params.user_id;
        await Experience.findByIdAndDelete({ _id: id });
        await User.findByIdAndUpdate({ _id: userId }, { $pull: { experience: id } });
        return res.send({ status: 'SUCCESS', message: 'Deleted!' })
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}