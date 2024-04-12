const mongoose = require("mongoose");

const Applicants = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    name: { type: String, default: null },
    contact_number: { type: String, default: null },
    email: { type: String, default: null },
    photograph: { type: Object, default: null },
    pan_card: { type: Object, default: null },
    aadhar_voter_card: { type: Object, default: null },
    passport_bank_statement: { type: Object, default: null },
    din_number: { type: String, default: null },
    shares: { type: Number, default: null }, //total shares and total share percentage
    is_aadhar_phone_linked: { type: Boolean, default: true },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("directors", Applicants);