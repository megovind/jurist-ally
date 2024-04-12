const passport = require("passport");
const express = require("express");
const router = express.Router();

const NotificationController = require("../../Controllers/Notifications");

router.post(
    "/update-notification-registration-token",
    passport.authenticate("jwt", { session: false }),
    NotificationController.update_registration_token
);

router.post(
    "/send-notification",
    NotificationController.send
)

router.post(
    "/fetch-notificaion/:id",
    passport.authenticate('jwt', { session: false }),
    NotificationController.fetch_notifications
);

module.exports = router;