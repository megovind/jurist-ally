const passport = require("passport");
const express = require("express");
const router = express.Router();

const EduController = require("../../Controllers/Education");

//to add education router
router.post(
    "/add-education/:id",
    passport.authenticate("jwt", { session: false }),
    EduController.add_education
);

//update education
router.patch(
    "/update-education/:id",
    passport.authenticate("jwt", { session: false }),
    EduController.update_education
);

//delete a education record
router.delete(
    "/delete-education/:id/:user_id",
    passport.authenticate("jwt", { session: false }),
    EduController.delete_education
);



module.exports = router;