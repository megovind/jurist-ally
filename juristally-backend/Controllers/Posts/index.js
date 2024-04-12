const mongoose = require("mongoose");
const _ = require("lodash");

const Posts = require("../../Models/Posts");
const Comment = require("../../Models/Posts/comments")
const User = require("../../Models/Auth");

const { notification_trigger } = require("../Notifications")

exports.create_post = async (req, res) => {
    try {
        const posts = new Posts({
            _id: new mongoose.Types.ObjectId(),
            user: req.body.user,
            content: req.body.content,
            media: req.body.media_content,
        });
        const response = await posts.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        const fetchPost = await Posts.findById({ _id: response._id })
            .populate("user", "_id full_name type profile_image designation")
            .populate('likes', '_id full_name type profile_image designation')
            .populate('shared_with', '_id full_name type profile_image designation')
            .populate("comments").exec();
        await notifyOnNewPost(req.body.user);
        return res.send({ status: "SUCCESS", response: fetchPost });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

const notifyOnNewPost = async (id) => {
    const user = await fetchUser(id);
    const users = await User.find({ followers: id }).select("_id full_name");
    users.forEach(async usr => {
        const title = "New Post Added!";
        const message = `${user.full_name} has posted new stories.`;
        await notification_trigger(usr._id, title, message);
    });
}

exports.update_post = async (req, res) => {
    try {
        const postId = req.params.id;
        const post = {
            content: req.body.content,
            media: req.body.media_content
        }
        const response = await Posts.findByIdAndUpdate({ _id: postId }, { $set: post }, { new: true });
        if (_.isEmpty(response)) {
            return res.send({ status: 'ERROR', message: 'Something went wrong!' });
        }
        const fetchPost = await Posts.findById({ _id: postId })
            .populate("user", "_id full_name type profile_image designation")
            .populate('likes', '_id full_name type profile_image designation')
            .populate('shared_with', '_id full_name type profile_image designation')
            .populate("comments").exec();
        return res.send({ status: "SUCCESS", response: fetchPost });
    } catch (error) {
        return res.send({ status: 'ERROR', message: "Post Can not be updated" });
    }
}

exports.fetch_posts = async (req, res) => {
    try {
        const PAGE_SIZE = 20;
        const pageNumber = req.query.page ? parseInt(req.query.page) : 1;
        const skip = (pageNumber - 1) * PAGE_SIZE;
        const response = req.query.page ? await Posts.find().sort({ $natural: -1 }).skip(skip).limit(PAGE_SIZE)
            .populate("user", "_id full_name type profile_image designation")
            .populate('likes', '_id full_name type profile_image designation')
            .populate('shared_with', '_id full_name type profile_image designation')
            .populate("comments").exec()
            : await Posts.find().sort({ $natural: -1 })
                .populate("user", "_id full_name type profile_image designation")
                .populate('likes', '_id full_name type profile_image designation')
                .populate('shared_with', '_id full_name type profile_image designation')
                .populate("comments").exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Posts not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_posts_by_user = async (req, res) => {
    try {
        const userId = req.params.id;
        const PAGE_SIZE = 20;
        const pageNumber = req.query.page ? parseInt(req.query.page) : 1;
        const skip = (pageNumber - 1) * PAGE_SIZE;
        const response = req.query.page ? await Posts.find({ user: userId }).sort({ $natural: -1 }).skip(skip).limit(PAGE_SIZE)
            .populate("user", "_id full_name type profile_image designation")
            .populate('likes', '_id full_name type profile_image designation')
            .populate('shared_with', '_id full_name type profile_image designation')
            .populate('comments').exec()
            : await Posts.find({ user: userId }).sort({ $natural: -1 })
                .populate("user", "_id full_name type profile_image designation")
                .populate('likes', '_id full_name type profile_image designation')
                .populate('shared_with', '_id full_name type profile_image designation')
                .populate('comments').exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "posts not found" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.delete_post = async (req, res) => {
    try {
        const postId = req.params.id;
        const response = await Posts.findByIdAndDelete({ _id: postId });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Post can not be deleted!" });
        }
        return res.send({ status: "SUCCESS", message: "Post deleted successfully!" })
    } catch (error) {
        return res.send({ status: "ERROR", message: "Post can not be deleted!" });
    }
}

exports.like_unlike_post = async (req, res) => {
    try {
        const user_id = req.params.user_id;
        const post_id = req.params.post_id;
        const post = await Posts.findById({ _id: post_id }).exec();
        if (_.isEmpty(post)) {
            return res.send({ status: "ERROR", message: "Post is not found!" });
        }
        const isLiked = post.likes.includes(user_id);
        if (isLiked) {
            const dislikedPost = await Posts.findByIdAndUpdate({ _id: post_id }, { $pull: { likes: user_id } }).exec();
            return res.send({ status: "SUCCESS", message: 'Post unliked', dislikedPost });
        }
        const likedPost = await Posts.findByIdAndUpdate({ _id: post_id }, { $push: { likes: user_id } }, { new: true }).populate("likes", "_id full_name profile_image designation");
        await notifyOnLike(user_id, post.user);
        return res.send({ status: "SUCCESS", message: "Post Liked!", likedPost });
    } catch (error) {
        return res.send({ status: "ERROR", message: "You will not be abe to like or unlike the post" });
    }
}

const notifyOnLike = async (id, byId) => {
    const user = await fetchUser(id);
    const title = "Your Post liked!";
    const message = `${user.full_name} just liked your story.`;
    await notification_trigger(byId, title, message);
}

exports.comment_on_post = async (req, res) => {
    try {
        const post_id = req.params.post_id;
        const user_id = req.params.user_id;
        const checkPost = await Posts.findById({ _id: post_id }).select('_id').exec();
        const commentBy = await User.findById({ _id: user_id }).exec();
        if (_.isEmpty(checkPost)) {
            return res.send({ status: 'ERROR', message: 'Post not found!' });
        }
        const comment = new Comment({
            _id: new mongoose.Types.ObjectId(),
            user: {
                _id: user_id,
                full_name: commentBy.full_name,
                profile_image: commentBy.profile_image,
                type: commentBy.type,
                designation: commentBy.designation
            },
            comment: req.body.comment,
        })
        const response = await comment.save();
        if (_.isEmpty(response)) {
            return res.send({ status: 'ERROR', message: 'You can not comment, something went wrong' });
        }
        const commentedPost = await Posts.findByIdAndUpdate({ _id: post_id }, { $push: { comments: response._id } });
        await notifyOnComment(user_id, commentedPost.user);
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "You can not make a comment on this post" });
    }
}

const notifyOnComment = async (id, byId) => {
    const user = await fetchUser(id);
    const title = "New Comment!";
    const message = `${user.full_name} has just commented on your story.`;
    await notification_trigger(byId, title, message);
}

const fetchUser = async (id) => {
    const response = await User.findById({ _id: id }).select("_id full_name type");
    return response;
}

exports.share_post = async (req, res) => {
    const post_id = req.params.post_id;
    const user_id = req.params.user_id;
}