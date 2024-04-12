const mongoose = require("mongoose");

const subscriptionSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, required: true, ref: "Users" },
    active_plan: { type: String, required: true, ref: "SubscriptionCard" },
    type: { type: String, required: true },
    start_date: { type: Date, default: Date.now },
    end_date: { type: Date, default: null },
    is_active: { type: Boolean, default: true },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Subscriptions", subscriptionSchema);