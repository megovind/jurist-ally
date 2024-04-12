const passport = require("passport");
const express = require("express");
const router = express.Router();

const PostController = require("../../Controllers/Posts");

router.post(
    "/create-post",
    passport.authenticate("jwt", { session: false }),
    PostController.create_post
);

router.post(
    "/update-post/:id",
    passport.authenticate("jwt", { session: false }),
    PostController.update_post
)

router.delete(
    "/delete-post/:id",
    passport.authenticate("jwt", { session: false }),
    PostController.delete_post
)

router.get(
    "/fetch-posts",
    passport.authenticate("jwt", { session: false }),
    PostController.fetch_posts
);

router.get(
    "/fetch-post-by-user/:id",
    passport.authenticate("jwt", { session: false }),
    PostController.fetch_posts_by_user
);


router.post(
    "/like-dislike-post/:user_id/:post_id",
    passport.authenticate("jwt", { session: false }),
    PostController.like_unlike_post
);

router.post(
    "/comment-on-post/:user_id/:post_id",
    passport.authenticate("jwt", { session: false }),
    PostController.comment_on_post
);

router.post(
    "/share-post/:user_id/:post_id",
    passport.authenticate("jwt", { session: false }),
    PostController.share_post
);


module.exports = router;