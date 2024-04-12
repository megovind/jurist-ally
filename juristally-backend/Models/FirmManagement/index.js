const mongoose = require("mongoose");

const firmSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    firm_name: { type: String, default: null },
    tagline: { type: String, default: null },
    short_description: { type: String, default: null },
    firm_email: { type: String, default: null },
    logo: { type: String, default: null },
    cover_photo: { type: String, default: null },
    webiste_url: { type: String, default: null },
    industry: { type: String, default: null },
    type: { type: String, default: null },
    firm_size: { type: String, default: null },
    jobs: [{ type: String, ref: 'Jobs' }],
    employees: [{ type: String, ref: 'Users' }],
    clients: [{ type: String, ref: "Users" }],
    admin: { type: String, ref: 'Users' },
    status: { type: String, default: 'Active' },
    is_verified: { type: Boolean, default: false },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Firms", firmSchema);