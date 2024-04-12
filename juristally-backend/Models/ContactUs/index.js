const mongoose = require("mongoose");

const contactUsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, default: null },
    customer_name: { type: String, required: true },
    customer_mail: { type: String, required: true },
    customer_contact: { type: String, required: true },
    issue: { type: String, required: true },
    status: { type: String, default: "open" },
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("ContactUs", contactUsSchema);
