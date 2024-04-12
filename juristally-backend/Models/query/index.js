const mongoose = require("mongoose");

const querySchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    query_id: { type: String, required: true },
    query_by: { type: String, ref: "Users", required: true },
    location: { type: Object, default: null },
    queried_to: [{ type: String, ref: 'Users' }],
    accepted_by: { type: String, ref: "Users", default: null },
    law_area: { type: String, ref: "Laws" },
    file: { type: String, default: null },
    looking_for: { type: String, default: null },
    query: { type: String, default: null },
    status: { type: String, default: "open" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("UserQuery", querySchema);
