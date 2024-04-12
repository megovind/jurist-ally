const mongoose = require("mongoose");

const exprerienceSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    company_name: { type: String, default: null },
    designation: { type: String, default: null },
    start_date: { type: Date, default: Date.now },
    end_date: { type: Date, default: Date.now },
    is_present: { type: Boolean, default: false },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Experience", exprerienceSchema);