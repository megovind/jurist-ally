const mongoose = require('mongoose');
const _ = require("lodash");

const Subscription = require("../../Models/Subscription");
const SubscriptionCard = require("../../Models/Subscription/subscription_card");

exports.fetch_user_subscription = async (req, res) => {
    try {
        const response = await Subscription.findOne({ $and: [{ user: req.params.user }, { is_active: true }] });
        if (_.isEmpty(response)) {
            return res.send({ status: 'NOT_FOUND', message: 'No active plan found!' });
        }
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}

exports.create_card = async (req, res) => {
    try {
        const card = new SubscriptionCard({
            _id: mongoose.Types.ObjectId(),
            type_text: req.body.type_text,
            tag_text: req.body.tag_text,
            descriptive_text: req.body.descriptive_text,
            actual_price: req.body.actual_price,
            discounted_price: req.body.discounted_price,
            per_text: req.body.per_text,
            off_text: req.body.off_text,
            is_trial: req.body.is_trial
        })
        const response = await card.save();
        if (_.isEmpty(response)) {
            return res.send({ status: 'ERROR', message: 'something went wrong' });
        }
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}

exports.fetch_subscription_card = async (req, res) => {
    try {
        const response = await SubscriptionCard.find().exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Cards details not found!" });
        }
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}