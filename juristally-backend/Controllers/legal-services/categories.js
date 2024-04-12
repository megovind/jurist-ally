const mongoose = require("mongoose");
const _ = require("lodash");

const services = require("../../services/legal-services.service");

exports.add_categories = async (req, res) => {
    try {
        const data = req.body;
        const response = await services.CREATE_CATEGORY(data)
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "Something went wrong!" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_category = async (req, res) => {
    try {
        const categoryId = req.params.id;
        const data = req.body;
        const type = await services.CREATE_SERVICE_TYPE(data)
        if (_.isEmpty(type)) return res.send({ status: "ERROR", message: "Something went wrong!" })
        const category = await services.UPDATE_CATEGORY(categoryId, { $push: { types: type._id } })
        return res.send({ status: "SUCCESS", category, type })
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_service_category = async (req, res) => {
    try {
        const category = req.query.category;
        const filter = req.query.category ? { category: req.query.category } : {};
        const usr = req.user._id;
        const categories = await services.FETCH_SERVICE_CATEGORIES(filter);  //Categories.find().populate("types");
        let applied_services;
        const data = { user: usr };
        if (category === 'business_registration') {
            applied_services = await services.FETCH_ALL_BUSINESS_REGISTRATION(data);
        } else if (category === 'dsc_registration') {
            applied_services = await services.FETCH_ALL_DSC_REGISTRATION(data);
        } else if (category === 'tax_fillings') {
            applied_services = await services.FETCH_ALL_ITR_GST_FILLINGS(data);
        }
        if (_.isEmpty(categories)) return res.send({ status: "ERROR", message: "Categories can not be fetched" })
        return res.send({ status: "SUCCESS", response: { categories, applied_services } });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

