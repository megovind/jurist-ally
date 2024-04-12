const mongoose = require("mongoose");
const _ = require("lodash");

const Laws = require("../../Models/LegalUpdates/laws")

exports.add_law_area = async (req, res) => {
    try {
        if (_.isEmpty(req.body.name)) {
            return res.send({ status: "ERROR", message: "Please provide law name!" });
        }
        const law = new Laws({
            _id: mongoose.Types.ObjectId(),
            law_name: req.body.name,
            lang: req.body.lang
        });
        const response = await law.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        return res.send({ status: "SUCCESS", message: "Law Added!", response })
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_law_area = async (req, res) => {
    try {
        const lang = req.query.lang
        // const query = req.query.q ? req.query.q : '';{ $and: [{ law_name: { $regex: new RegExp(query) } }, { lang: lang }] }
        const response = await Laws.find().exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Law areas not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

