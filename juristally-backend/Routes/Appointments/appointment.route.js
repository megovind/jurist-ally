const passport = require("passport");
const express = require("express");
const router = express.Router();

const AppointmentController = require("../../controllers/appointment");

router.post(
    "/book-appointment",
    passport.authenticate("jwt", { session: false }),
    AppointmentController.book_an_appointment
);

router.post(
    "/fetch-appointments/:type/:id",
    passport.authenticate('jwt', { session: false }),
    AppointmentController.appointments
);

router.post(
    "/fetch-appointment/:id",
    passport.authenticate("jwt", { session: false }),
    AppointmentController.fetch_appointment_by_id
);


module.exports = router;

