const passport = require("passport");
const express = require("express");
const router = express.Router();

const AppointmentController = require("../../Controllers/Appointment");


router.post(
    "/book-appointment",
    passport.authenticate("jwt", { session: false }),
    AppointmentController.book_an_appointment
);
//to be deprecated
router.post(
    "/fetch-appointments-booked-by/:id",
    passport.authenticate('jwt', { session: false }),
    AppointmentController.appointments_booked_by
);
//to be deprecated
router.post(
    '/fetch-appointments-booked-to/:id',
    passport.authenticate('jwt', { session: false }),
    AppointmentController.appointments_booked_to
)

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

