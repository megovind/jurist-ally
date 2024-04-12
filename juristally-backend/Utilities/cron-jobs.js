const _ = require("lodash");
const moment = require("moment")

const Litigations = require("../Models/Litigations");
const Subscription = require("../Models/Subscription");
const User = require("../Models/Auth")
const OTPS = require("../Models/Auth/otp");
const PasswordTokens = require("../Models/Auth/password_token");
const Appointment = require("../Models/Appointment");

const { send_sms } = require("./send_sms");
const { send_mails } = require("./send_mail")
const { notification_trigger } = require("../Controllers/Notifications/index");


const litigations = async () => {
    let litigation = [];
    const response = await Litigations.find().populate("user_id", "_id full_name contact_number email");
    response.forEach(resp => {
        if (resp.next_hearing_date != null) {
            litigation.push({
                uid: resp.user_id._id,
                phone: resp.user_id.contact_number,
                email: resp.user_id.email,
                name: resp.user_id.full_name,
                next_hearing_date: resp.next_hearing_date.hearing_date,
                message: resp.next_hearing_date.order_passed,
                case_number: resp.case_number
            });
        }
    })
    return litigation;

}

const add_days = (date, days) => {
    return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}
const substract_days = (date, days) => {
    return new Date(date.getTime() - days * 24 * 60 * 60 * 1000);
}

const nextHearingDateReminder = async days => {
    const litigation = await litigations();
    //check if the hearing date comes after today or today
    const afterDays = add_days(new Date(), days);
    const activeLit = litigation.filter(data => data.next_hearing_date.split("T")[0] == afterDays.toISOString().split("T")[0]);
    activeLit.forEach(async d => {
        const message = text_message(d.case_number, d.next_hearing_date);
        const notificationmsg = notification_message(d.case_number, d.next_hearing_date);
        const title = "Next Hearing Date";
        const emailMessage = email_message(d)
        send_sms(d.phone, message);
        await send_mails(d.email, title, emailMessage);
        await notification_trigger(d.uid, title, notificationmsg)
    });
}

const email_message = (d) => {
    return `<div><p>Dear ${d.name},</p>

        <p> This is an update about your Case Number ${d.case_number} with party. </p>
        <br />
        <p> Next Hearing Date :<b>${moment(d.next_hearing_date).format("LL")}</b> </p>
        <p>  Last Order Passed: <b>${d.message}</b> </p>
        <br />
        <p> Make sure to update your MIS for further updates.</p>
        <br />
        <p>Warm Regards,</p>
        <p>JuristAlly Team</p> </div>`

}

const text_message = (case_number, date) => {
    const message = `Your case number ${case_number} next hearing date is ${date}.

    Team 
    JuristAlly`;
    return message;
}

const notification_message = (casenumber, date) => {
    return `Your case# ${casenumber}'s next hearing date is ${moment(date).format("LL")}`;
}

const fetchSubscription = async () => {
    let subscriptions = [];
    const response = await Subscription.find({ is_active: true }).populate("user", "_id full_name designation type contact_number email").populate("active_plan", "is_trial");
    response.forEach(resp => {
        subscriptions.push({
            uid: resp.user._id,
            username: resp.user.full_name,
            email: resp.user.email,
            phone: resp.user.contact_number,
            subid: resp._id,
            startDate: resp.start_date,
            endDate: resp.end_date,
            type: resp.type,
            isInTrial: resp.active_plan.is_trial,
        });
    });
    return subscriptions;
}

const non_subscribers = async () => {
    let users = [];
    const response = await User.find();
    const filteredUsrs = response.filter(usr => usr.type != "other" || usr.subscription != null);
    filteredUsrs.forEach(usr => {
        users.push({
            uid: usr._id,
            type: usr.type,
            username: usr.full_name,
            email: usr.email,
            phone: usr.contact_number,
            isTrialDone: usr.is_trial_done
        });
    });
    return users;
}

const getPasswordTokens = async () => {
    let tokens = [];
    const response = await PasswordTokens.find();
    response.forEach(tks => {
        tokens.push({
            id: tks._id,
            expiresAt: tks.expire_at
        });
    });
    return tokens;
}

const getOTPs = async () => {
    let otps = [];
    const response = await OTPS.find();
    response.forEach(otp => {
        otps.push({
            id: otp._id,
            expiresAt: otp.expires_at
        });
    })
    return otps;
}

const non_subscribers_reminder = async () => {
    const users = await non_subscribers();
    users.forEach(async usr => {
        const textmessage = "Subscribe to Juristally to use premium services";
        const email_message = non_subscrib_email(usr);
        const subject = "JuristAlly";
        const noticationMessage = "Get a premium membership to use most features";
        const title = "JuristAlly";
        // send_sms(usr.phone, textmessage);
        // await send_mails(usr.email, subject, email_message);
        await notification_trigger(usr.uid, title, noticationMessage);
    });
}

const removeTokensOTPs = async () => {
    const currentDate = new Date().valueOf();
    const tokens = await getPasswordTokens();
    const otps = await getOTPs();
    tokens.forEach(async tkns => {
        const expires = new Date(tkns.expiresAt).valueOf();
        if (currentDate > expires) {
            await PasswordTokens.findByIdAndDelete({ _id: tkns.id });
        }
    });
    otps.forEach(async otp => {
        const expires = new Date(otp.expiresAt).valueOf();
        if (currentDate > expires) {
            await OTPS.findByIdAndDelete({ _id: otp.id });
        }
    });
}

const non_subscrib_email = () => {
    return `<div>
        <p>Dear JuristAlly User,</p>
        <br />
        <p>Here is your chance to <b>UPGRADE</b> to <b>GOLD MEMBER</b> @ just <b> Rs 1000/per year</b>.
    To upgrade now click here: <a href="https://play.google.com/store/apps/details?id=com.jurist_ally&hl=en_IN" target="blank">Download Juristally</a> </p>
    <br/>
        <p>Team,</p>
        <p>JuristAlly</p>
    </div>`;
}

const subscription_reminder = async days => {
    const subscription = await fetchSubscription();
    const afterDays = add_days(new Date(), days);
    const filteredList = subscription.filter(data => data.endDate.split("T")[0] == afterDays.toISOString().split("T")[0]);
    filteredList.forEach(async sub => {
        const message = subscrioption_text(sub);
        const notificationmsg = subscription_notification(sub);
        const title = "Juristally: Subscription Reminder";
        send_sms(d.phone, message);
        await notification_trigger(d.uid, title, notificationmsg)
    });
}

const update_subscription = async () => {
    const subscription = await fetchSubscription();
    const date = new Date();
    const filteredList = subscription.filter(data => data.endDate.toISOString().split("T")[0] <= date.toISOString().split("T")[0]);
    filteredList.forEach(async sub => {
        console.log(sub.uid);
        if (sub.isInTrial) {
            console.log("isInTrial");
            console.log(sub.uid);
            await User.findByIdAndUpdate({ _id: sub.uid }, { $set: { subscription: null, is_trial_done: true, is_in_trial: false } });
        }
        console.log("not in trial");
        console.log(sub.uid);
        await User.findByIdAndUpdate({ _id: sub.uid }, { $set: { subscription: null } });
        await Subscription.findByIdAndUpdate({ _id: sub.subid }, { $set: { is_active: false } });
        const message = subscription_text(sub);
        const notificationmsg = subscription_notification(sub);
        const title = "Juristally: Subscription Reminder";
        const mail_message = subscriptionmail_message(sub);
        send_sms(d.phone, message);
        await send_mails(d.email, title, mail_message);
        await notification_trigger(d.uid, title, notificationmsg)
    });
}

const subscriptionmail_message = (sub) => {
    return message = sub.isInTrial ? `<div>
        <p>Dear ${sub.username}, </p>
        <br />
        <p>Your <b>free trial</b> plan for juristally paid services has ended, Please subscribe back to cantinue using all the premium services.</p>
        <p>Team,</p>
        <p>JuristAlly</p></div>`
        : `<div> <p>Dear ${sub.username},</p>
            <br />
            <p>Your <b>${sub.type}</b> subscription plan for juristally has ended, please subscribe back to continue using premium services.</p>
            <p>Team,</p>
            <p>JuristAlly</p></div>`
        ;
}

const subscription_text = (sub) => {
    const message = sub.isInTrial ? `Your free trial for Juristally has ended, subscribe back to continue using services, Thanks` : `Your ${sub.type} subscription for Juristally has ended, please subscribe back to continue using premium services, Thanks`;
    return message;
}

const subscription_notification = (sub) => {
    const message = sub.isInTrial ? "Free trial has ended, subscribe back to continue using services." : `Your ${sub.type} subscription has ended subscribe back to continue premium services.`;
    return message;
}


// update user about the next appointment booked to/by
const getAppointments = async () => {
    let appointments = [];
    const response = await Appointment.find()
        .populate("booked_by", "_id full_name contact_number email type")
        .populate("booked_to", "_id full_name contact_number email type");
    response.forEach(appoint => {
        appointments.push({
            appNo: appoint.appointment_no,
            interval: appoint.interval,
            date: appoint.date_of_appointment,
            bookedById: appoint.booked_by._id,
            bookedByName: appoint.booked_by.full_name,
            bookedByEmail: appoint.booked_by.email,
            bookedByPhone: appoint.booked_by.contact_number,
            bookedByType: appoint.booked_by.type,
            bookedToId: appoint.booked_to._id,
            bookedToName: appoint.booked_to.full_name,
            bookedToEmail: appoint.booked_to.email,
            bookedToPhone: appoint.booked_to.contact_number,
            bookedToType: appoint.booked_to.type
        });
    });
    return appointments;
}


const triggerRemindForAppointment = async days => {
    const appointments = await getAppointments();
    const afterDays = add_days(new Date(), days);
    const filteredList = appointments.filter(data => data.date.split("T")[0] == afterDays.toISOString().split("T")[0]);
    filteredList.forEach(async data => {
        //booked to
        const bookedTo = await user(data.bookedToId);
        const bookedBy = await user(data.bookedById);
        const bookedToMailText = mailTextFormat(bookedBy, bookedTo, data.date, data.interval);
        const bookedTomailSubject = `JuristAlly: Appointment Reminder`;
        const bookedTotitle = `JuristAlly: Appointment Reminder`;
        const bookedTonotifyMessageText = `You have an appointment on ${moment(data.date).format("LL")} at ${getTimeInterval(data.interval)} by ${bookedBy.full_name}`;
        await alertUser(bookedTo, bookedTonotifyMessageText, bookedTotitle, bookedTomailSubject, bookedToMailText, bookedTonotifyMessageText);

        //booked by
        const bookedByMailText = mailTextFormat(bookedBy, bookedTo, data.date, data.interval, true);
        const bookedBymailSubject = `JuristAlly: Appointment Reminder`;
        const bookedBytitle = "JuristAlly: Appointment Reminder";
        const bookedBynotifyMessageText = `You have an appointment on ${moment(data.date).format("LL")} at ${getTimeInterval(data.interval)} with ${bookedTo.full_name}.`;
        await alertUser(bookedBy, bookedBynotifyMessageText, bookedBytitle, bookedBymailSubject, bookedByMailText, bookedBynotifyMessageText);
    });
}

const user = async (id) => {
    return await User.findById({ _id: id }).select("_id full_name email contact_number designation type profile_image")
}

const alertUser = async (user, textSMS, title, mailSubject, mailText, notifyMessage) => {
    send_sms(user.contact_number, textSMS);
    await send_mails(user.email, mailSubject, mailText);
    await notification_trigger(user._id, title, notifyMessage);
}

const mailTextFormat = (by, to, dateOfAppointment, interval, isBy = false) => {
    if (isBy) {
        return `<div>
        <p>Hi ${by.full_name},</p>
        <br />
        <p>You have an appointment booked with <b>${to.full_name}</b> on <b>${moment(dateOfAppointment).format("LL")}</b> at  <b>${getTimeInterval(interval)}</b></p>
        <br />
        <p>Thank you,</p>
        <p>JuristAlly Team</p>
        </div>`;
    } else {
        return `<div>
        <p>Hi ${to.full_name},</p>
        <br />
        <p>You have an appointment booked by <b>${by.full_name}</b> on <b>${moment(dateOfAppointment).format("LL")}</b> at <b>${getTimeInterval(interval)}</b> with you. </p>
        <br />
        <p>Thank you,</p>
        <p>JuristAlly Team</p>
        </div>`;;
    }
}



module.exports.runNextHearingDateCron = async () => {
    await nextHearingDateReminder(5);
    await nextHearingDateReminder(2);
}

module.exports.reminderForAppointments = async () => {
    await triggerRemindForAppointment(2);
    await triggerRemindForAppointment(1);
}

module.exports.subscription_reminder = async () => {
    // await subscription_reminder(3);
    // await subscription_reminder(1);
}

module.exports.allTimeCron = async () => {
    await removeTokensOTPs();
}

module.exports.update_subscriptions = async () => {
    await update_subscription();
}

module.exports.non_subscriptionCron = async () => {
    await non_subscribers_reminder();
}