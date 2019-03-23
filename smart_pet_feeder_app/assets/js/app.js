// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import feeder_management from "./feeder_management"


/////////////////////

var wsbroker = "31.13.251.48";  // mqtt websocket enabled broker
var wsport = 15675; // port for above

var client = new Paho.MQTT.Client(wsbroker, wsport, "/ws",
    "myclientid_" + parseInt(Math.random() * 100, 10));
client.onConnectionLost = function (responseObject) {
    console.log("CONNECTION LOST - " + responseObject.errorMessage);
};
client.onMessageArrived = function (message) {
    console.log("RECEIVE ON " + message.destinationName + " PAYLOAD " + message.payloadString);
    console.log(message.payloadString);
};

var options = {
    timeout: 10,
    onSuccess: function () {
        console.log("CONNECTION SUCCESS");
        client.subscribe('/topic/test', { qos: 1 });
    },
    onFailure: function (message) {
        console.log("CONNECTION FAILURE - " + message.errorMessage);
    }
};
if (location.protocol == "https:") {
    options.useSSL = true;
}
console.log("CONNECT TO " + wsbroker + ":" + wsport);
client.connect(options);

////////////////////



let csrf = document.querySelector("meta[name=csrf]").content;

$('#login').on('click', function () {

    let username = $("#username").val();
    let password = $("#password").val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/login_user",
        data: {
            "username": username,
            "password": password
        },
        success: function (msg) {
            console.log(msg);

            $.ajax({
                method: "POST",
                headers: {
                    "X-CSRF-TOKEN": csrf
                },
                data: {
                    token: msg.response.token,
                    username: username
                },
                url: "/set_auth_configs",
                success: function (msg) {
                    console.log(msg)
                },
                error: function (xhr, status) {
                    console.log("Error on setting auth configs.");
                }
            });
        },
        error: function (xhr, status) {
            console.log("Error on login.");
        }
    });
});

$('#register').on('click', function () {
    let username = $("#username").val();
    let password = $("#password").val();
    let email = $("#email").val();
    let first_name = $("#first_name").val();
    let last_name = $("#last_name").val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/register_user",
        data: {
            "username": username,
            "password": password,
            "email": email,
            "first_name": first_name,
            "last_name": last_name
        },
        success: function (msg) {
            console.log(msg)
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
});