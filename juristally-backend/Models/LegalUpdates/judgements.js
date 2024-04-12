const mongoose = require("mongoose");

const judgements = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    court_name: { type: String, required: true },
    title: { type: String, required: true },
    file: { type: String, required: true },
    year: { type: String, required: true },
    date_of_judgement: { type: Date, default: Date.now },
    reference: { type: String, default: null },
    reference_link: { type: String, default: null },
    lang: { type: String, default: "en" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Judgements", judgements);