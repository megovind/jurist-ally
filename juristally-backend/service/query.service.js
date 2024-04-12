const mongoose = require("mongoose");

const models = require("../models");


exports.CREATE_QUERY = async (data) => {
    const query = new models.Query({ _id: mongoose.Types.ObjectId(), ...data });
    const response = await query.save();
    return response;
}

exports.FIND_QUERY_BY_ID = async (data) => await models.Query.findById(data)
    .populate('queried_to', "_id full_name designation type profile_image")
    .populate('query_by', "_id full_name designation type profile_image")
    .populate("accepted_by", "_id full_name designation type profile_image")
    .populate("law_area", "_id law_name");

exports.QUERY_COUNT = async (data) => await models.Query.countDocuments(data);

exports.FIND_QUERIES = async (data) => await models.Query.find(data)
    .populate('queried_to', "_id full_name designation type profile_image")
    .populate('query_by', "_id full_name designation type profile_image")
    .populate("accepted_by", "_id full_name designation type profile_image")
    .populate("law_area", "_id law_name");
;