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
import socket from "./socket"
import feeder_management from "./feeder_management"
import pet_management from "./pet_management"

let csrf = document.querySelector("meta[name=csrf]").content;

$('#login_page').on('click', function () {
    window.location.href = "/login";
});

$('#register_page').on('click', function () {
    window.location.href = "/register";
});

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
                    // Do some token validation and redirect
                    window.location.href = "/pet_management";
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