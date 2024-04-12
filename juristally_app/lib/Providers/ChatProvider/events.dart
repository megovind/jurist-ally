class CHATEVENTS {
  static const int LISTEN_PORT = 4002;
  static const int STATUS_MESSAGE_NOT_SENT = 10001;
  static const int STATUS_MESSAGE_SENT = 10002;
  static const String CONNECTION = "connection";
  static const String UPDATE_USER_STATUS = "update_user_status";
  static const String STATUS_UPDATE = "status_update";
  static const String USER_STATUS = "user_status";
  static const String DISCONNECT = "disconnect";
  static const String CONNECT = "connect";
  static const String IS_USER_CONNECTED = "is_user_connected";
  static const String EVENT_IS_USER_ONLINE = "check_online";

  static const String GET_ALL_CHAT_ROOM = "GET_ALL_CHAT_ROOMS";
  static const String ROOMS = "rooms";
  static const String START_NEW_CHAT = "start_new_chat";
  static const String NEW_CHAT = "new_chat";
  static const String LOAD_ALL_MESSAGE = "load_all_messages";
  static const String MESSAGES = "messages";
  static const String SEND_MESSAGE = "send_messages";
  static const String RECIEVE_MESSAGE_ERROR = "recieve_message_error";
  static const String RECIEVE_MESSAGE = "receive_message";

  static const String START_EVENT = "start_event";
  static const String REFRESH_EVENT = "refresh_event";
  static const String END_EVENT = "end_event";
  static const String PARTICIPANT_JOINING = "participant_joining";
  static const String PARTICIPANT_LEAVING = "participant_leaving";
  static const String RAISE_HAND = "raise_hand";
  static const String HANDRAISED = "handraised";
  static const String OPPOSE_FAVOUR_EVENTS = "oppose_favour_events";
  static const String VOTE_FOR_PARTICIPANT = "vote_for_participant";
  static const String MUTE_A_USER = "mute_a_user";

  static const String ERROR = "error";
}
