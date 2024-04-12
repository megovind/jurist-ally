const mongoose = require("mongoose");

mongoose.Promise = require("bluebird");

const http = require('http');
const app = require('./index');
const ioSocket = require('socket.io');
const { stringify } = require('querystring');
const { add_user_list, fetch_chatlist, save_messages, fetch_all_message } = require("./v1/message-app/chat-controller")

const port = process.env.PORT || 5000;

const server = http.createServer(app);

const io = ioSocket(server);

// Reserved Events
const ON_CONNECTION = 'connection';
const ON_DISCONNECT = 'disconnect';

//Main Events
const EVENT_IS_USER_ONLINE = 'check_online';
const EVENT_SINGLE_CHAT_MESSAGE = 'single_chat_message';

// Sub Events
const SUB_EVENT_RECEIVE_MESSAGE = 'receive_message';
const SUB_EVENT_MESSAGE_FROM_SERVER = 'message_from_server';
const SUB_EVENT_IS_USER_CONNECTION = 'is_user_connected';

const FETCH_CHAT_MESSAGE = 'fetch_chat_messages';
const FETCH_USERS_EVENT = 'fetch_users';

// Status
const STATUS_MESSAGE_NOT_SENT = 10001;
const STATUS_MESSAGE_SENT = 10002;

// This map has all the users connected
const userMap = new Map();

io.set('transports', ['websocket']);

io.sockets.on(ON_CONNECTION, (socket) => {
    onEachUserConnection(socket);
});

// this is for the private chat/single chat
const onMessage = (socket) => {
    socket.on(EVENT_SINGLE_CHAT_MESSAGE, (chat_message) => {
        singleChatHandler(socket, chat_message);
    });
}

//check if the user is online
const checkOnline = (socket) => {
    socket.on(EVENT_IS_USER_ONLINE, (chat_user_data) => {
        checkOnlineHandler(socket, chat_user_data);
    });
}



//emit user data
const emitUsers = async (socket) => {
    const newdata = await fetch_chatlist(socket.handshake.query.from);
    socket.emit("fetch_users", stringifyJson(newdata));
}


//emit chat messages
const emitChatMessages = async (socket, chat_data) => {
    const newdata = await fetch_all_message(socket.handshake.query.from, chat_data.to);
    print("usersss:  " + stringifyJson(newdata))
    socket.emit("fetch_chat_messages", stringifyJson(newdata));
}

// on user get disconnect
const onUserDisconnect = (socket) => {
    onDisconnect(socket);
}




// this fctn is fired when each use is connect to socket
const onEachUserConnection = (socket) => {
    print('--------------------------------');
    print('Connected => Socket ID ' + socket.id + ',  User: ' + JSON.stringify(socket.handshake.query));

    let from_user_id = socket.handshake.query.from;

    //ADD TO MAP
    let userMapVal = { socket_id: socket.id };
    addUserToMap(from_user_id, userMapVal);
    print(userMap);
    printNumOnlineUsers();

    emitUsers(socket);
    onMessage(socket);
    checkOnline(socket);
    onUserDisconnect(socket);
}

// need to do all the operations here like add user to my group and store its messages
const singleChatHandler = (socket, chat_message) => {
    print("Message: " + stringify(chat_message));

    // get the 'to' user....
    const to_user_id = chat_message.to;
    const from_user_id = chat_message.from;

    print(from_user_id + ' => ' + to_user_id);

    const to_user_socket_id = getSocketIDfromMapForthisUser(to_user_id);
    const userOnline = userFoundOnMap(to_user_id);

    print('to_user_socket_id: ' + to_user_socket_id + ', userOnline: ' + userOnline);

    //store user to db
    add_user_list(from_user_id, to_user_id);
    save_messages(chat_message);
    if (!userOnline) {
        print('To chat user not connected');
        chat_message.message_sent_status = STATUS_MESSAGE_NOT_SENT;
        chat_message.to_user_online_status = false;
        sendBackToClient(socket, SUB_EVENT_MESSAGE_FROM_SERVER);
        return;
    }

    //User Connected adn his socket ID found on the userMap
    chat_message.message_sent_status = STATUS_MESSAGE_SENT;
    chat_message.to_user_online_status = true;
    sendToConnectedSocket(socket, to_user_socket_id, SUB_EVENT_RECEIVE_MESSAGE, chat_message);

    //sending status back to client
    //update the chat id adn send back
    chat_message.message_sent_status = STATUS_MESSAGE_SENT;
    chat_message.to_user_online_status = false;
    sendBackToClient(socket, SUB_EVENT_MESSAGE_FROM_SERVER, chat_message);

    print("Message sent!");

}

const checkOnlineHandler = (socket, chat_user_data) => {
    const to_user_id = chat_user_data.to;
    print("Checking online user: " + to_user_id);
    emitChatMessages(socket, chat_user_data);
    const to_user_socket_id = getSocketIDfromMapForthisUser(`${to_user_id}`);
    const user_online = userFoundOnMap(to_user_id);

    print("To user socket id: " + to_user_socket_id);

    chat_user_data.message_sent_status = user_online ? STATUS_MESSAGE_SENT : STATUS_MESSAGE_NOT_SENT;
    chat_user_data.to_user_online_status = user_online ? true : false;
    sendBackToClient(socket, SUB_EVENT_IS_USER_CONNECTION, chat_user_data);
}

const onDisconnect = (socket) => {
    socket.on(ON_DISCONNECT, () => {
        print("Disconneted " + socket.id);
        removeUserWithSocketIdFromMap(socket.id); // need to remove user from the 
        socket.removeAllListeners('message');
        socket.removeAllListeners('disconnected');
    });
}

const addUserToMap = (key_user_id, val) => {
    userMap.set(key_user_id, val);
}

const removeUserWithSocketIdFromMap = (socket_id) => {
    print("Deleting user with socket id: " + socket_id);
    let toDeleteUser;
    for (const key of userMap) {
        // index 1, return the value
        const userMapValue = key[1];

        if (userMapValue.socket_id == socket_id) {
            toDeleteUser = key[0];
        }
    }
    print("Deleting user: " + toDeleteUser);
    if (undefined != toDeleteUser) {
        userMap.delete(toDeleteUser);
    }
    print(userMap);
    printNumOnlineUsers();
}
const getSocketIDfromMapForthisUser = (to_user_id) => {
    const userMapVal = userMap.get(`${to_user_id}`);
    if (userMapVal == undefined) {
        return undefined;
    }
    return userMapVal.socket_id;
}

const sendBackToClient = (socket, event, message) => {
    socket.emit(event, stringifyJson(message))
}

const sendToConnectedSocket = (socket, to_user_socket_id, event, message) => {
    socket.to(`${to_user_socket_id}`).emit(event, stringifyJson(message));
}

const userFoundOnMap = (to_user_id) => {
    const to_user_socket_id = getSocketIDfromMapForthisUser(`${to_user_id}`);
    return to_user_socket_id != undefined;
}

// Always stringfy to create proper json sending

const stringifyJson = (data) => {
    return JSON.stringify(data);
}

const print = (logData) => {
    console.log(logData);
}

const printNumOnlineUsers = () => {
    print('Online users: ' + userMap.size);
}


