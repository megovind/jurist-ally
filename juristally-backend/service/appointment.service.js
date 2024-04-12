const mongoose = require("mongoose");

const models = require("../models");

exports.INSERT_APPOINTMENT = async (data) => {
    const appointment = new models.Appointment({ _id: new mongoose.Types.ObjectId(), ...data });
    const response = await appointment.save();
    return response;
}

exports.FIND_BOOKEDTO_APPOINTNENT = async (id) => await models.Appointment.findById({ _id: id })
    .populate('booked_to', '_id full_name designation type location profile_image')
    .populate('query');


exports.FIND_BOOKED_APPOINTNENT = async (id) => await models.Appointment.findById({ _id: id })
    .populate('booked_by', '_id full_name contact_number email designation type location profile_image')
    .populate('booked_to', '_id full_name contact_number email designation type location profile_image')
    .populate('query');


exports.FIND_APPOINTMENTS = async (data) => await models.Appointment.find(data)
    .populate('booked_by', '_id full_name contact_number email designation type location profile_image')
    .populate('booked_to', '_id full_name contact_number email designation type location profile_image')
    .populate('query');

exports.APPOINTMENT_COUNT = async (data) => await models.Appointment.countDocuments(data);