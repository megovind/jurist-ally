const mongoose = require("mongoose");

const bareActsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    bare_act: { type: String, required: true, default: null },
    file: { type: String, default: null, required: true },
    lang: { type: String, default: "en" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});
// bareActsSchema.index({ '$**': 'text' });
module.exports = mongoose.model("BareAct", bareActsSchema);