const _ = require('lodash');
const moment = require("moment");

const { send_sms } = require("../../utilities/send_sms");
const { send_mails } = require("../../utilities/send_mail");
const { notification_trigger } = require("../../controllers/notifications/notification.controller")

const appointmentService = require("../../services/appointment.service");
const userService = require("../../services/auth.service");

exports.book_an_appointment = async (req, res) => {
    try {
        const booked_by = req.query.booked_by;
        const booked_to = req.query.booked_to;
        const dateOfAppointment = req.body.date_of_appointment;
        const interval = req.body.time_interval;
        const appointCount = await appointmentService.APPOINTMENT_COUNT({ booked_to: req.query.booked_to });
        const appointmentNo = createId("APP#", appointCount);
        const data = {
            booked_by: booked_by,
            booked_to: booked_to,
            appointment_no: appointmentNo,
            query: req.query.query,
            ...req.body
        };
        const response = await appointmentService.INSERT_APPOINTMENT({ ...data });
        const resp = await appointmentService.FIND_BOOKEDTO_APPOINTNENT(response._id);
        if (_.isEmpty(resp)) {
            return res.send({ status: 'ERROR', message: 'Something went wrong' });
        }
        //booked to
        const bookedTo = await userService.FIND_USER_BY_ID(booked_to);
        const bookedBy = await userService.FIND_USER_BY_ID(booked_by);
        const bookedToMailText = mailTextFormat(bookedBy, bookedTo, dateOfAppointment, interval);
        const bookedTomailSubject = `Appointment Booked By ${bookedBy.full_name}`;
        const bookedTotitle = `Appointment Booked By ${bookedBy.full_name}`;
        const bookedTonotifyMessageText = `New Appointment ${appointmentNo} booked on ${moment(dateOfAppointment).format("LL")} between ${getTimeInterval(interval)} by ${bookedBy.full_name}`;
        await alertUser(bookedTo, bookedTonotifyMessageText, bookedTotitle, bookedTomailSubject, bookedToMailText, bookedTonotifyMessageText);

        //booked by
        const bookedByMailText = mailTextFormat(bookedBy, bookedTo, dateOfAppointment, interval, true);
        const bookedBymailSubject = `JuristAlly: New Appointment!`;
        const bookedBytitle = "Appointment Booked";
        const bookedBynotifyMessageText = `${appointmentNo} booked on ${moment(dateOfAppointment).format("LL")} between ${getTimeInterval(interval)} to ${bookedTo.full_name} by you`;
        await alertUser(bookedBy, bookedBynotifyMessageText, bookedBytitle, bookedBymailSubject, bookedByMailText, bookedBynotifyMessageText);
        return res.send({ status: 'SUCCESS', response: resp });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

const alertUser = async (user, textSMS, title, mailSubject, mailText, notifyMessage) => {
    send_sms(user.contact_number, textSMS);
    await send_mails(user.email, mailSubject, mailText);
    await notification_trigger(user._id, title, notifyMessage);
}

const userType = [
    { type: 'lawyer', vlaue: 'Lawyer' },
    { type: 'company_secretary', value: 'Company Secretary' },
    { type: 'student', value: 'Student' },
    { type: 'chartered_accountant', value: "Chartered Accountant" },
    { type: 'hr', value: 'Human Resources(HR)' },
];

const mailTextFormat = (by, to, dateOfAppointment, interval, isBy = false) => {
    if (isBy) {
        return `<div>
        <p>Hi ${by.full_name},</p>
        <br />
        <p>New appointment is booked by you. Please find details below</p>
        <p>Booked with <b>${to.full_name}</b></p>
        <p>Booked on <b>${moment(dateOfAppointment).format("LL")}</b></p>
        <p>Time: <b>${getTimeInterval(interval)}</b></p>
        <br />
        <p>Thank you,</p>
        <p>JuristAlly Team</p>
        </div>`;
    } else {
        return `<div>
        <p>Hi ${to.full_name},</p>
        <br />
        <p>New appointment is booked with you. Please find details below</p>
        <p>Booked by <b>${by.full_name}</b></p>
        <p>Booked on <b>${moment(dateOfAppointment).format("LL")}</b></p>
        <p>Time: <b>${getTimeInterval(interval)}</b></p>
        <br />
        <p>Thank you,</p>
        <p>JuristAlly Team</p>
        </div>`;;
    }
}



const getTimeInterval = (interval) => {
    if (interval === "09-12") {
        //09-12
        return '09 AM - 12 Noon'
    } else if (interval === "12-03") {
        //12-03
        return "12 Noon - 03 PM"
    } else {
        //03-06
        return "03 PM - 06 PM"
    }
}

exports.fetch_appointment_by_id = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await appointmentService.FIND_BOOKED_APPOINTNENT(id);
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Appointments not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.appointments = async (req, res) => {
    try {
        const id = req.user._id;
        const type = req.user.type;
        let data;
        if (type === 'lawyer' || type === 'company_secretary' || type === 'chartered_accountant') {
            data = { $or: [{ booked_by: id }, { booked_to: id }] };
        } else {
            data = { booked_by: id };
        }
        const response = await appointmentService.FIND_APPOINTMENTS(data);
        if (_.isEmpty(response)) {
            return res.send({ status: 'NOT_FOUND', message: "Appointments not booked by you!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


const createId = (type, count) => {
    let result = "";
    const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const text = charset.charAt(Math.floor(Math.random() * charset.length));
    if (count < 9) {
        result = type.toUpperCase() + "0" + (count + 1);
    } else {
        result = type.toUpperCase() + (count + 1);
    }
    return result;
};