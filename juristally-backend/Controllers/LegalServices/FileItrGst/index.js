const mongoose = require("mongoose");
const _ = require("lodash");

const Director = require("../../../Models/LegalServices/director");
const LegalServices = require("../../../Models/LegalServices/business_registration");
const { create_updates } = require("../../Payments/update_order");

exports.file_itr_gst = async (req, res) => {
    try {
        const director = new Director({
            _id: mongoose.Types.ObjectId(),
            name: req.body.name,
            contact_number: req.body.contact_number,
            email: req.body.email,
            is_aadhar_phone_linked: req.body.is_aadhar_phone_linked,
            passport_bank_statement: req.body.passport_bank_statement,
            aadhar_voter_id: req.body.aadhar_voter_id,
            pan_card: req.body.pan_card,
        });
        const applicantResponse = await director.save();
        if (_.isEmpty(applicantResponse)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        const data = new LegalServices({
            _id: mongoose.Types.ObjectId(),
            user: req.body.user,
            type: req.body.type,
            location: req.body.location,
            handler: process.env.NODE_ENV != 'development' ? ['5f951cf65d576e34c096f0a4'] : ["60161e7c1596bf2bd976232d", "5fdaec800a606032b56bea0a"],
            applicant_details: applicantResponse._id,
            f_year: req.body.f_year,
            gst_number: req.body.gst_number,
            month_year: req.body.month_year,

        });
        const taxResponse = await data.save();
        if (_.isEmpty(taxResponse)) {
            return res.send({ status: "ERROR", message: "Application can not be completed!" });
        }
        await create_updates(req.body.category, taxResponse._id);
        const response = await LegalServices.findById({ _id: taxResponse._id })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type")
            .populate("type").populate("applicant_details");
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong!" });
    }
}

exports.update_itr_gst = async (req, res) => {
    try {
        const sId = req.params.id;
        const invoice = req.body.invoice;
        invoice != null
            ? await LegalServices.findByIdAndUpdate({ _id: sId }, { $push: { invoices: req.body.invoice } })
            : await LegalServices.findByIdAndUpdate({ _id: sId }, { $set: req.body });

        const response = await LegalServices.findById({ _id: sId })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type")
            .populate("type").populate("applicant_details");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong!" });
    }
}

exports.update_itr_gst_details = async (req, res) => {
    try {
        const sId = req.params.sId;
        const dId = req.params.dId;
        const data = req.body;
        if (!_.isNull(dId)) { await Director.findByIdAndUpdate({ _id: dId }, { $set: data }) };
        await LegalServices.findByIdAndUpdate({ _id: sId }, { $set: data });
        const response = await LegalServices.findById({ _id: sId })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type")
            .populate("type").populate("applicant_details");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Data not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong!" });
    }
}