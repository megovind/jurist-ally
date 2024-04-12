import 'package:juristally/Providers/ChatProvider/events.dart';
import 'package:juristally/data/network/api_urls.dart';

import 'package:socket_io_client/socket_io_client.dart';

class ChatUtils {
  Socket connectToServer(String? token) {
    try {
      Socket socket = io(
        '${ApiUrls.CHAT_URL}',
        OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .enableAutoConnect() // disable auto-connection
            .disableForceNew()
            .setQuery({"Authorization": "JWT $token"})
            .disableForceNewConnection()
            .disableMultiplex()
            .setReconnectionDelay(10) // for Flutter or Dart VM
            .build(),
      );
      socket.on(CHATEVENTS.CONNECTION, (data) {
        print("ONCONNECTION:: $data");
      });
      socket.onConnect((data) {
        print("ONCONNECT $data");
        print("${socket.connected}");
      });
      socket.onConnectError((data) => print(data));
      socket.onError((data) => print("CHAT: SOCKETERROR: $data"));
      return socket;
    } catch (e) {
      throw e;
    }
  }

  diconnectocket(Socket socket) => socket.disconnect();

  checkOnlineListner({required String? userId, required Function callBack, required Socket socket}) {
    socket.emit(CHATEVENTS.IS_USER_CONNECTED, {userId});
    socket.on(CHATEVENTS.USER_STATUS, (data) => callBack(data));
  }

  fetchAllRoomsListners({String? userId, required Function fetchAllRooms, required Socket socket}) {
    socket.emit(CHATEVENTS.GET_ALL_CHAT_ROOM, {"userId": userId});
    socket.on(CHATEVENTS.ROOMS, (data) => fetchAllRooms(data));
  }

  sendMessageListner({Map<String, dynamic>? data, required Socket socket}) {
    socket.emit(CHATEVENTS.START_NEW_CHAT, data);
  }

  newChatStartListner({required Function callback, required Socket socket}) {
    socket.on(CHATEVENTS.NEW_CHAT, (d) => callback(d));
  }

  Future<void> loadMessages({Map<String, dynamic>? data, required Function callback, required Socket socket}) async {
    socket.emit(CHATEVENTS.LOAD_ALL_MESSAGE, data);
    socket.on(CHATEVENTS.MESSAGES, (d) => callback(d));
  }

  sendMessage({Map<String, dynamic>? data, required Socket socket}) {
    socket.emit(CHATEVENTS.SEND_MESSAGE, data);
  }

  // Listen to all message events from connected users
  handleMessage({required Function callBack, required Socket socket}) {
    socket.on(CHATEVENTS.RECIEVE_MESSAGE, (d) {
      print("CHAT: NEW MESSAGE, $d");
      callBack(d);
    });
  }

  onRefreshEventHandler({required Function refreshEvent, required Socket socket}) {
    socket.on(CHATEVENTS.REFRESH_EVENT, (data) {
      print("REFRESHED");
      refreshEvent(data);
    });
  }

  onEventErrorHandler({required Function onErrorCallBack, required Socket socket}) {
    socket.on(CHATEVENTS.ERROR, (data) => onErrorCallBack(data));
  }

  // Audio Call Stuff
  startEventHandler({Map<String, dynamic>? data, required Socket socket}) {
    print("STARTED EVENET :: $data");
    socket.emit(CHATEVENTS.START_EVENT, data);
  }

  endEventHandler({Map<String, dynamic>? data, required Socket socket}) {
    socket.emit(CHATEVENTS.END_EVENT, data);
  }

  participantJoinEventHandler({Map<String, dynamic>? data, required Socket socket}) {
    print("JONIGNNN::: $data");
    socket.emit(CHATEVENTS.PARTICIPANT_JOINING, data);
  }

  particpantLeavingEventHandler({Map<String, dynamic>? data, required Socket socket}) {
    print("LEAVIINGGG:: $data");
    socket.emit(CHATEVENTS.PARTICIPANT_LEAVING, data);
  }

  muteAUser({required Map<String, dynamic> data, required Socket socket}) {
    print("AT MUTE:  $data");
    socket.emit(CHATEVENTS.MUTE_A_USER, data);
  }

  raiseHandHandler({Map<String, dynamic>? data, required Socket socket}) {
    print("RAISE HAND  $data");
    socket.emit(CHATEVENTS.RAISE_HAND, data);
  }

  onHandRaised({required Function callback, required Socket socket}) {
    socket.on(CHATEVENTS.HANDRAISED, (data) => callback(data));
  }

  opposeFavourEvent({Map<String, dynamic>? data, required Socket socket}) {
    socket.emit(CHATEVENTS.OPPOSE_FAVOUR_EVENTS, data);
  }

  voteForParticipant({Map<String, dynamic>? data, required Socket socket}) {
    socket.emit(CHATEVENTS.VOTE_FOR_PARTICIPANT, data);
  }
}
