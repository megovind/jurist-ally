const mongoose = require("mongoose");

const models = require("../models");

exports.INSERT_NEWS = async (data) => {
    const news = new models.News({ _id: new mongoose.Types.ObjectId(), ...data });
    const response = await news.save();
    return response;
}

exports.UPDATE_NEWS = async (id, data) => await models.News.findByIdAndUpdate({ _id: id }, { $set: data }, { new: true });

exports.FIND_NEWS = async (SORT, SKIP, PAGE_SIZE, data) => await models.News.find(data).sort({ created_at: SORT }).skip(SKIP).limit(PAGE_SIZE).populate("law_area").exec();

exports.FIND_NEW_BY_ID = async (id) => await models.News.findById({ _id: id }).populate("law_area").exec();