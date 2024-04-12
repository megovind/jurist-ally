const mongoose = require("mongoose");
const _ = require("lodash");

const Firm = require("../../Models/FirmManagement");
const User = require("../../Models/Auth");


exports.create_firm_page = async (req, res) => {
    try {
        const id = req.params.user_id;
        const firm = new Firm({
            _id: mongoose.Types.ObjectId,
            firm_name: req.body.name,
            tagline: req.body.tagline,
            short_description: req.body.short_description,
            website_url: req.body.website_url,
            firm_email: req.body.firm_email,
            industry: req.body.industry,
            type: req.body.type,
            logo: req.body.logo,
            admin: id
        });
        const response = await firm.save();
        if (_.isEmpty(response)) {
            return res.send({ status: 'ERROR', message: 'Something went wrong!' });
        }
        await User.findByIdAndUpdate({ _id: id }, { $set: { current_firm: response._id } });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_firm = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Firm.findById({ _id: id });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Firm is not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.check_firm = async (req, res) => {
    const query = req.query.q;
    try {
        const response = await Firm.find({ firm_name: { $regex: query } });
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Firm not found!" });
        }
        return res.send({ status: "EXISTS", message: "This firm is already exists. Please ask admin to make you admin" });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


exports.fetch_firms_employees_clients = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Firm.findById({ _id: id })
            .populate("employees", "full_name email contact_number profile_image")
            .populate("clients", "full_name email contact_number profile_image");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Firm is not registred" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.add_employee_to_firm = async (req, res) => {
    try {
        const firmId = req.params.firm_id;
        const userId = req.params.user_id;
        const response = await Firm.findOneAndUpdate({ _id: firmId }, { $push: { eployees: user_id } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Firm cant't be updated" });
        }
        await User.findByIdAndUpdate({ _id: userId }, { $set: { current_firm: response._id } });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}