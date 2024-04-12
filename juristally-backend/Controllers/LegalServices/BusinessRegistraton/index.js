const mongoose = require("mongoose");
const _ = require("lodash");

const LegalServices = require("../../../Models/LegalServices/business_registration/index");
const Directors = require("../../../Models/LegalServices/director");
const LegalServiceUpdates = require("../../../Models/LegalServices/updates");
const { create_updates } = require("../../../Controllers/Payments/update_order");

exports.register_service = async (req, res) => {
    try {
        const service = new LegalServices({
            _id: mongoose.Types.ObjectId(),
            user: req.body.user,
            type: req.body.type,
            location: req.body.location,
            objective: req.body.objective,
            preferred_company_names: req.body.preferred_company_name,
            capital: req.body.capital,
            handler: process.env.NODE_ENV != 'development' ? ['5f951cf65d576e34c096f0a4'] : ["60161e7c1596bf2bd976232d", "5fdaec800a606032b56bea0a"]
        });
        const saved = await service.save();
        if (_.isEmpty(saved)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        await create_updates(req.body.category, saved._id);
        const response = await LegalServices.findById({ _id: saved._id })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details")
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.update_service = async (req, res) => {
    try {
        const id = req.params.id;
        const data = {
            location: req.body.location,
            preferred_company_names: req.body.preferred_company_name,
        }
        const response = await LegalServices.findByIdAndUpdate({ _id: id }, { $set: data }, { new: true })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Service can not be updated" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" })
    }
}

exports.update_address_proof = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const response = await LegalServices.findByIdAndUpdate({ _id: id }, { $set: { address_proof: data } }, { new: true })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Address proof can not be updated" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.register_director = async (req, res) => {
    try {
        const id = req.params.id;
        const data = new Directors({
            _id: mongoose.Types.ObjectId(),
            name: req.body.name,
            contact_number: req.body.contact_number,
            email: req.body.email,
            photograph: req.body.photograph,
            pan_card: req.body.pan_card,
            aadhar_voter_id: req.body.aadhar_voter_id,
            passport_bank_statment: req.body.passport_bank_statment,
            din_number: req.body.din_number,
            shares: req.body.shares
        });
        const applicant = await data.save();
        if (_.isEmpty(applicant)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        const response = await LegalServices.findByIdAndUpdate({ _id: id }, { $push: { applicant_details: applicant._id } }, { new: true })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.update_director_details = async (req, res) => {
    try {
        const dId = req.params.d_id;
        const sId = req.params.s_id;
        const data = req.body;
        const director = await Directors.findByIdAndUpdate({ _id: dId }, { $set: data });
        if (_.isEmpty(director)) {
            return res.send({ status: "ERROR", message: "Applicant details can not be updated" });
        }
        const response = await LegalServices.findById({ _id: sId }).populate("updates")
            .populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.delete_director = async (req, res) => {
    try {
        const dId = req.params.d_id;
        const sId = req.params.s_id;
        const removed = await Directors.findByIdAndRemove({ _id: dId });
        const response = await LegalServices.findByIdAndUpdate({ _id: sId }, { $pull: { applicant_details: dId } }, { new: true })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        if (_.isEmpty(removed)) {
            return res.send({ status: "ERROR", message: "Applicant can't be removed" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.fetch_Services_by_user = async (req, res) => {
    try {
        const usr = req.params.user;
        const response = await LegalServices.find({ user: usr }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Services not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}


exports.fetch_service = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await LegalServices.findById({ _id: id }).populate("updates")
            .populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Service not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.fetch_incomplete_service = async (req, res) => {
    try {
        const typeId = req.params.type_id;
        const userId = req.params.user_id;
        const response = await LegalServices.findOne({ $and: [{ type: typeId }, { user: userId }, { status: "incomplete" }] })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Please fill in the details" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}

exports.fetch_Services_by_handler = async (req, res) => {
    try {
        const id = req.params.handler_id;
        const response = await LegalServices.find({ handler: id })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details").exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "There is no services found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong!" });
    }
}

exports.update_legal_service_updates = async (req, res) => {
    try {
        const id = req.params.id;
        const file = req.body.file;
        const data = {
            status: req.body.status,//Objection//unverified//verified//done
            handler_message: req.body.handler_message,
            applicant_message: req.body.applicant_message,
            updated_at: Date.now(),
        };
        if (!_.isNull(file)) {
            await LegalServiceUpdates.findByIdAndUpdate({ _id: id }, { $push: { files: file } });
        }
        const update = await LegalServiceUpdates.findByIdAndUpdate({ _id: id }, { $set: data });
        if (_.isEmpty(update)) {
            return res.send({ status: "ERROR", message: "Can not update" });
        }
        const response = await LegalServices.findById({ _id: update.service })
            .populate("updates")
            .populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type")
            .populate("type").populate("applicant_details").exec();
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}
