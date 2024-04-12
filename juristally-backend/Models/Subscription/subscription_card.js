const mongoose = require("mongoose");

const subscriptionCardSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    type_text: { type: String, required: true },
    tag_text: { type: String, required: true },
    descriptive_text: { type: String, required: true },
    actual_price: { type: String, required: true },
    discounted_price: { type: String, required: true },
    per_text: { type: String, required: true },
    off_text: { type: String, required: true },
    is_trial: { type: Boolean, default: false }
});

module.exports = mongoose.model("SubscriptionCard", subscriptionCardSchema);