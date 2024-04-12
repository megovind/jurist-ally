const mongoose = require("mongoose");
const _ = require("lodash");


const Education = require("../../Models/Education");
const User = require("../../Models/Auth");

exports.add_education = async (req, res) => {
    try {
        const user_id = req.params.id;
        const education = new Education({
            _id: mongoose.Types.ObjectId(),
            type: req.body.ed_type,
            institute_name: req.body.institute_name,
            stream: req.body.stream,
            start_date: req.body.start_date,
            end_date: req.body.end_date,
            is_present: req.body.is_present
        });
        const response = await education.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        await User.findByIdAndUpdate({ _id: user_id }, { $push: { education: response._id } });
        return res.send({ status: "SUCCESS", response })
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_education = async (req, res) => {
    try {
        const id = req.params.id;
        const data = {
            type: req.body.ed_type,
            institute_name: req.body.institute_name,
            stream: req.body.strem,
            start_date: req.body.start_date,
            end_date: req.body.end_date,
            is_present: req.body.is_present
        };
        const response = await Education.findByIdAndUpdate({ _id: id }, { $set: data }, { new: true });
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Record is not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.delete_education = async (req, res) => {
    try {
        const id = req.params.id;
        const userId = req.params.user_id;
        await Education.findByIdAndDelete({ _id: id });
        await User.findByIdAndUpdate({ _id: userId }, { $pull: { education: id } });
        return res.send({ status: 'SUCCESS', message: 'Deleted!' })
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}