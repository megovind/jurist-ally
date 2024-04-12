const mongoose = require("mongoose");
const _ = require("lodash");

const Categories = require("../../Models/LegalServices/services");
const ServiceTypes = require("../../Models/LegalServices/service-type");
const LegalServices = require("../../Models/LegalServices/business_registration")

exports.add_categories = async (req, res) => {
    try {
        const category = new Categories({
            _id: mongoose.Types.ObjectId(),
            title: req.body.title,
            description: req.body.description,
            category: req.body.category
        });
        const response = await category.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR" })
    }
}

exports.update_category = async (req, res) => {
    try {
        const categoryId = req.params.id;
        const type = new ServiceTypes({
            _id: mongoose.Types.ObjectId(),
            title: req.body.title,
            description: req.body.description,
            category: req.body.category,
            price: req.body.price,
            min_dir: req.body.min_dir,
            max_dir: req.body.max_dir
        })
        const typesResp = await type.save();
        if (_.isEmpty(typesResp)) {
            return res.send({ status: "ERROR" })
        }
        const cateResp = await Categories.findByIdAndUpdate({ _id: categoryId }, { $push: { types: typesResp._id } });
        return res.send({ status: "SUCCESS", cateResp, typesResp })
    } catch (error) {
        return res.send({ status: "ERROR" })
    }
}

exports.fetch_service_category = async (req, res) => {
    try {
        const usr = req.params.user;
        const response = await Categories.find().populate("types");
        const services = await LegalServices.find({ user: usr }).populate("updates")
            .populate("type").populate("user", "_id full_name email contact_number type").populate("handler", "_id full_name email contact_number type").populate("applicant_details").exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Categories can not be fetched" })
        }
        return res.send({ status: "SUCCESS", response, services });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Categories can not be fetched" })
    }
}

