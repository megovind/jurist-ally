const passport = require("passport");
const express = require("express");
const router = express.Router();

const ExperienceController = require("../../Controllers/Experience");

//to add experience
router.post(
    "/add-experience/:id",
    passport.authenticate("jwt", { session: false }),
    ExperienceController.add_experience
);

//update experience
router.patch(
    "/update-experience/:id",
    passport.authenticate("jwt", { session: false }),
    ExperienceController.update_experience
);

//delete an experience
router.delete(
    "/delete-experience/:id/:user_id",
    passport.authenticate("jwt", { session: false }),
    ExperienceController.delete_experience
);


module.exports = router