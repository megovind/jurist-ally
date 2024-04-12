const mongoose = require("mongoose");
const _ = require("lodash");

const ContactUs = require("../../Models/ContactUs");

exports.contact_us = async (req, res) => {
    try {
        const contact = new ContactUs({
            _id: mongoose.Types.ObjectId(),
            user: req.params.id,
            customer_name: req.body.customer_name,
            customer_mail: req.body.customer_mail,
            customer_contact: req.body.customer_contact,
            issue: req.body.issue
        })
        const response = await contact.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        return res.send({ status: "SUCCESS", message: "Your query has reached to us, we will resolve as soon as possible, Thank You!" });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}

exports.get_request = async (req, res) => {
    try {
        const contact = new ContactUs({
            _id: mongoose.Types.ObjectId(),
            customer_name: req.body.customer_name,
            customer_mail: req.body.customer_mail,
            customer_contact: req.body.customer_contact,
            issue: req.body.issue
        })
        const response = await contact.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        return res.send({ status: "SUCCESS", message: "Your query has reached to us, we will resolve as soon as possible, Thank You!" });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}