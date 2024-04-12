const mongoose = require("mongoose");

const models = require("../models").LegalServices;

exports.CREATE_BUSINESS_REGISTRATION = async (data) => {
    const service = new models.BusinessRegistration({
        _id: mongoose.Types.ObjectId(),
        ...data
    });
    const response = await service.save();
    return response;
}

exports.CREATE_DSC_REGISTRATION = async (data) => {
    const service = new models.DSCRegistration({
        _id: mongoose.Types.ObjectId(),
        ...data
    });
    const response = await service.save();
    return response;
}

exports.CREATE_ITR_GST_FILLINGS = async (data) => {
    const service = new models.ItrGstFillings({
        _id: mongoose.Types.ObjectId(),
        ...data
    });
    const response = await service.save();
    return response;
}


exports.UPDATE_BUSINESS_REGISTRATION = async (id, data) => await models.BusinessRegistration.findByIdAndUpdate({ _id: id }, data, { new: true })
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");


exports.UPDATE_DSC_REGISTRATION = async (id, data) => await models.DSCRegistration.findByIdAndUpdate({ _id: id }, data, { new: true })
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type");

exports.UPDATE_ITR_GST_FILLINGS = async (id, data) => await models.ItrGstFillings.findByIdAndUpdate({ _id: id }, data, { new: true })
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type");


exports.INSERT_SERVICE_UPDATES = async (data) => await models.Updates.insertMany(data, { ordered: true });

exports.UPDATE_SERVICE_UPDATES = async (id, data) => await models.Updates.findByIdAndUpdate({ _id: id }, data, { new: true });

exports.FETCH_BUSINESS_REGISTRATION = async (data) => await models.BusinessRegistration.findOne(data)
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");


exports.FETCH_DSC_REGISTRATION = async (data) => await models.DSCRegistration.findOne(data)
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type");


exports.FETCH_ITR_GST_FILLING = async (data) => await models.ItrGstFillings.findOne(data)
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type");


exports.FETCH_ALL_BUSINESS_REGISTRATION = async (data) => await models.BusinessRegistration.find(data)
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type").populate("applicant_details");

exports.FETCH_ALL_DSC_REGISTRATION = async (data) => await models.DSCRegistration.find(data)
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type");

exports.FETCH_ALL_ITR_GST_FILLINGS = async (data) => await models.ItrGstFillings.find(data)
    .populate("updates").populate("user", "_id full_name email contact_number type")
    .populate("handler", "_id full_name email contact_number type").populate("type");



exports.CREATE_DIRECTOR = async (data) => {
    const director = new models.Directors({
        _id: mongoose.Types.ObjectId(),
        ...data
    });
    const response = await director.save();
    return response;
}

exports.UPDATE_DIRECTOR = async (id, data) => await models.Directors.findByIdAndUpdate({ _id: id }, data, { new: true });

exports.DELETE_DIRECTOR = async (id) => await models.Directors.findByIdAndRemove({ _id: id });

// Category
exports.CREATE_CATEGORY = async (data) => {
    const category = new models.Services({
        _id: mongoose.Types.ObjectId(),
        ...data
    });
    const response = await category.save();
    return response;
}

exports.CREATE_SERVICE_TYPE = async (data) => {
    const serviceType = new models.Servicetypes({
        _id: mongoose.Types.ObjectId(),
        ...data
    });
    const response = await serviceType.save();
    return response;
}

exports.UPDATE_CATEGORY = async (id, data) => await models.Services.findByIdAndUpdate({ _id: id }, data, { new: true });

exports.FETCH_SERVICE_CATEGORIES = async (data) => await models.Services.find(data).populate("types");
