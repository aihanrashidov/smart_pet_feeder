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
import Swal from 'sweetalert2'

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

            if (msg.response == "username") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing username.</label></div>"
                );
            }
            else if (msg.response == "password") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing password.</label></div>"
                );
            }
            else if (msg.response == "both") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing username and password.</label></div>"
                );
            }
            else {
                if (msg.response == "incorrect_usr_or_pass") {
                    Swal.fire(
                        'Login Error!',
                        'Wrong username or password.',
                        'error'
                    )
                } else {
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
                }
            }
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



            if (msg.response == "all") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing username, password, email, first name and last name.</label></div>"
                );
            }
            else if (msg.status == "error_all") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids' style='text-align: center;'><label>&#8226; <span  id='inv_text'>Missing " + msg.response + ".</span></label></div>"
                );
            }
            else {
                $('#invalid').html('');
                if (msg.status == "ok") {
                    Swal.fire({
                        title: 'Registration Successful!',
                        html:
                            'Your account has been registered.<br>' +
                            'You can now <a href="/login">login</a>.',
                        type: 'success'
                    })
                } else {
                    if (msg.response == "username") {
                        $('#invalid').html('');
                        $('#invalid').append(
                            "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Username error.</label></div>"
                        );
                        Swal.fire({
                            title: 'Registration Error!',
                            html:
                                'Failed to register account.<br><br>' +
                                '<div id="reg_fails">' +
                                '<label style="padding-left: 20px;">Your username:</label>' +
                                '<ul>' +
                                '<li>Must be between 2 and 12 characters long.</li>' +
                                '<li>Can contain any letters from a to z or A to Z and any numbers from 0 through 9.</li>' +
                                '<li>Can contain some special characters - underscore or dash.</li>' +
                                '</ul>.' +
                                '</div>',
                            type: 'error'
                        })
                    }
                    else if (msg.response == "password") {
                        $('#invalid').html('');
                        $('#invalid').append(
                            "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Password error.</label></div>"
                        );
                        Swal.fire({
                            title: 'Registration Error!',
                            html:
                                'Failed to register account.<br><br>' +
                                '<div id="reg_fails">' +
                                '<label style="padding-left: 20px;">Your password:</label>' +
                                '<ul>' +
                                '<li>Must be between 4 and 20 characters long.</li>' +
                                '<li>Can contain any letters from a to z or A to Z and any numbers from 0 through 9.</li>' +
                                '</ul>.' +
                                '</div>',
                            type: 'error'
                        })
                    }
                    else if (msg.response == "email") {
                        $('#invalid').html('');
                        $('#invalid').append(
                            "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Email error.</label></div>"
                        );
                        Swal.fire({
                            title: 'Registration Error!',
                            html:
                                'Failed to register account.<br>' +
                                'Invalid email address.',
                            type: 'error'
                        })
                    }
                    else if (msg.response == "first_name") {
                        $('#invalid').html('');
                        $('#invalid').append(
                            "<div id='invalids'><label>&#8226;</label><label id='inv_text'>First name error.</label></div>"
                        );
                        Swal.fire({
                            title: 'Registration Error!',
                            html:
                                'Failed to register account.<br><br>' +
                                '<div id="reg_fails">' +
                                '<label style="padding-left: 20px;">Your first name:</label>' +
                                '<ul>' +
                                '<li>Must be between 2 and 20 characters long.</li>' +
                                '<li>Can contain any letters from a to z or A to Z.' +
                                '</ul>.' +
                                '</div>',
                            type: 'error'
                        })
                    }
                    else if (msg.response == "last_name") {
                        $('#invalid').html('');
                        $('#invalid').append(
                            "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Last name error.</label></div>"
                        );
                        Swal.fire({
                            title: 'Registration Error!',
                            html:
                                'Failed to register account.<br><br>' +
                                '<div id="reg_fails">' +
                                '<label style="padding-left: 20px;">Your last name:</label>' +
                                '<ul>' +
                                '<li>Must be between 2 and 20 characters long.</li>' +
                                '<li>Can contain any letters from a to z or A to Z.' +
                                '</ul>.' +
                                '</div>',
                            type: 'error'
                        })
                    }

                }
            }

        },
        error: function (xhr, status) {
            $('#invalid').html('');
            console.log("Error!")
        }
    });
});