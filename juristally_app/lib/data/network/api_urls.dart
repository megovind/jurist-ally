class ApiUrls {
  // static const String BASE_URL = "http://192.168.137.90:3001/v1/"; //'https://dev.juristally.com/v1/';
  // static const String CHAT_URL = "http://192.168.137.90:3001/"; //"http://18.220.248.20:3001/";

  static const String CHAT_URL = "https://dev.opyin.com/";
  static const String BASE_URL = "https://dev.opyin.com/v1/"; //"http://18.220.248.20:3001/";

  //utilities
  static const String FILE_UPLOAD = "utilities/upload-file";
  static const String GENRATE_TOKEN = "utilities/generate-rtc-token";

  static const String SIGNUP_SIGNIN = 'auth/signin-singup';
  static const String SIGNUP_SIGNINOTP = 'auth/verify-singup-signin-otp';
  static const String REFRESH_TOKEN = 'auth/refresh-token';
  static const String DEACTIVATE_ACCOUNT = "auth/deactivate-account";

  static const String NOTIFICATION_TOKEN = "user/save-reg-token";
  static const String UPDATE_PROFILE = "user/update-profile";
  static const String FOLLOW_UNFOLLOW = "user/follow-unfollow";
  static const String FETCH_PROFILE = "user/fetch-user";
  static const String ADD_EDUCATION = "user/add-education";
  static const String UPDATE_EDUCATION = "user/update-education";
  static const String DELETE_EDUCATION = "user/delete-education";
  static const String ADD_EXPERIENCE = "user/add-experience";
  static const String UPDATE_EXPERIENCE = "user/update-experience";
  static const String DELETE_EXPERIENCE = "user/delete-experience";
  static const String ADD_ACHIEVEMENT = "user/add-achievement";
  static const String UPDATE_ACHIEVEMENT = "user/update-achievement";
  static const String DELETE_ACHIEVEMENT = "user/delete-achievement";
  static const String FETCH_USERS = "user/fetch-users";
  //Notifications
  static const String FETCH_NOTIFICATIONS = "user/fetch-notifications";
  static const String UPDATE_NOTIFICATION = "user/update-notification";

  //Events
  static const String CREATE_EVENT = "events/create-event";
  static const String ACCEPT_INVITATION = "events/accept-invitation";
  static const String FETCH_EVENTS = "events/fetch-events";
  static const String UPDATE_EVENT = "events/update-event";
  static const String ADD_PARTICIPANT = "event/add-participant";
  static const String REMOVE_PARTICIPANT = "event/remove-participant";
  static const String ADD_UPDATE_MARKING = "event/add-update-marking";
  static const String LIKE_UNLIKE_EVENT = "event/like-unlike-event";
  static const String AUDIO_COMMENT_EVENT = "event/audio-comment";
  static const String UPLOAD_DOCUMENTS = "event/upload-document";

  // Legal Library
  static const String FETCH_LEGAL_UPDATES = "legal-updates/fetch-legal-updates";
  static const String FETCH_BARE_ACTS = "bare-acts/fetch-bare-acts";
  static const String FETCH_ARTICLES = "articles/fetch-articles";
  static const String FETCH_JUDGEMENTS = "judgements/fetch-judgements";

  // Small  talls
  static const String CREATE_SMALL_TALK = "small-talk/create-small-talk";
  static const String UPDATE_SMALL_TALK = "small-talk//update-small-talk";
  static const String FETCH_SMALL_TALK = "small-talk/fetch-small-talks";
  static const String LIKE_DISLIKE_SMALL_TALK = "small-talk/like-dislike-small-talk";
  static const String COMMENT_SMALL_TALK = "small-talk/comment-small-talk";
  static const String DELETE_SMALL_TALK = "small-talk/delete-small-talk";
}
