const mongoose = require("mongoose");
const _ = require("lodash");

const Director = require("../../../Models/LegalServices/director")
const LegalService = require("../../../Models/LegalServices/business_registration")
const { create_updates } = require("../../Payments/update_order");

exports.dsc_registration = async (req, res) => {
    try {
        const director = new Director({
            _id: mongoose.Types.ObjectId(),
            name: req.body.name,
            contact_number: req.body.contact_number,
            email: req.body.email,
            photograph: req.body.photograph,
            pan_card: req.body.pan_card,
            aadhar_voter_id: req.body.aadhar_voter_id
        })
        const directorResponse = await director.save();
        if (_.isEmpty(directorResponse)) {
            return res.send({ status: "ERROR", message: "Applicant can't be added" });
        }
        const dsc = new LegalService({
            _id: mongoose.Types.ObjectId(),
            user: req.body.user,
            type: req.body.type,
            token: req.body.token,
            handler: process.env.NODE_ENV != 'development' ? ['5f951cf65d576e34c096f0a4'] : ["60161e7c1596bf2bd976232d", "5fdaec800a606032b56bea0a"],
            applicant_details: directorResponse._id,
        })
        const dscResponse = await dsc.save();
        if (_.isEmpty(dscResponse)) {
            return res.send({ status: "ERROR", message: "Application can not be completed!" });
        }
        await create_updates(req.body.category, dscResponse._id);
        const response = await LegalService.findById({ _id: dscResponse._id })
            .populate("updates").populate("user", "_id full_name email contact_number type")
            .populate("handler", "_id full_name email contact_number type")
            .populate("type").populate("applicant_details");
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}