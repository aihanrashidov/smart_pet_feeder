
import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })
socket.connect()

let channel = socket.channel("feeder:communication", {})
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

export default socket

let csrf = document.querySelector("meta[name=csrf]").content;

let username_conf = "";
let token_conf = "";

let selector = document.getElementById('select_operation');

function get_configs() {
    username_conf = $('#username_conf').val();
    token_conf = $('#token_conf').val();
}

let water_btn_status = "";
let food_btn_status = "";

$(document).ready(function () {
    $('#btn_toggle').hide();
    initial_load_feeders();
    load_feeders();
});

function initial_load_feeders() {
    get_configs()

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        data: {
            "token": token_conf,
            "username": username_conf
        },
        url: "/get_feeders",
        success: function (msg) {
            console.log(msg)

            if (msg.response.length == 0) {
                $('#display_feeders').html(
                    "<div id='no_feeders'><label>You have no feeders added.</label></div>"
                );
            }
            else {
                let feeders = "";
                for (let i = 0; i < msg.response.length; i++) {
                    channel.on(msg.response[i].serial + "_app", msg => {
                        console.log("Got message from agent: " + msg.message.serial, msg)
                        let top_water_sensor = msg.message.sensors_data.top_water_sensor
                        let bottom_water_sensor = msg.message.sensors_data.bottom_water_sensor;
                        let feeder_id = msg.message.feeder_id;

                        $.ajax({
                            method: "POST",
                            headers: {
                                "X-CSRF-TOKEN": csrf
                            },
                            url: "/update_feeder_status",
                            data: {
                                "username": username_conf,
                                "token": token_conf,
                                "top_water_sensor": top_water_sensor,
                                "bottom_water_sensor": bottom_water_sensor,
                                "feeder": feeder_id
                            },
                            success: function (msg) {
                                console.log(msg)
                            },
                            error: function (xhr, status) {
                                console.log("Error!")
                            }
                        });
                    }
                    )

                    if (msg.response[i].water_status == "No water.") {
                        water_btn_status = "enabled";
                    }
                    else {
                        water_btn_status = "disabled";
                    }

                    if (msg.response[i].food_status != "Okay") {
                        food_btn_status = "disabled";
                    }
                    else {
                        food_btn_status = "enabled";
                    }

                    console.log(water_btn_status);

                    feeders = feeders +
                        "<div id='feeder_id_" + msg.response[i].id + "'>" +
                        "<label>Serial number: " + msg.response[i].serial + "</label>" +
                        "<label>Device status: " + msg.response[i].device_status + "</label>" +
                        "<label>Water status: " + msg.response[i].water_status + "</label>" +
                        "<button id='fill_water' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + water_btn_status + ">Fill Water</button>" +
                        "<label>Food status: " + msg.response[i].food_status + "</label>" +
                        "<button id='fill_food' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + food_btn_status + ">Fill Food</button>" +
                        "</div>"
                }

                $('#display_feeders').html(
                    feeders
                );
            }
        },
        error: function (xhr, status) {
            console.log("Error on getting feeders.");
        }
    });
}

function load_feeders() {
    get_configs()

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        data: {
            "token": token_conf,
            "username": username_conf
        },
        url: "/get_feeders",
        success: function (msg) {
            console.log(msg)

            if (msg.response.length == 0) {
                $('#display_feeders').html(
                    "<div id='no_feeders'><label>You have no feeders added.</label></div>"
                );
            }
            else {
                let feeders = "";
                for (let i = 0; i < msg.response.length; i++) {
                    let water_btn_status = "";
                    let food_btn_status = "";

                    channel.push(msg.response[i].serial + "_agent", msg.response)

                    if (msg.response[i].water_status == "No water.") {
                        water_btn_status = "enabled";
                    }
                    else {
                        water_btn_status = "disabled";
                    }

                    if (msg.response[i].food_status != "Okay") {
                        food_btn_status = "disabled";
                    }
                    else {
                        food_btn_status = "enabled";
                    }

                    feeders = feeders +
                        "<div id='feeder_id_" + msg.response[i].id + "'>" +
                        "<label>Serial number: " + msg.response[i].serial + "</label>" +
                        "<label>Device status: " + msg.response[i].device_status + "</label>" +
                        "<label>Water status: " + msg.response[i].water_status + "</label>" +
                        "<button id='fill_water' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + water_btn_status + ">Fill Water</button>" +
                        "<label>Food status: " + msg.response[i].food_status + "</label>" +
                        "<button id='fill_food' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + food_btn_status + ">Fill Food</button>" +
                        "</div>"
                }

                $('#display_feeders').html(
                    feeders
                );
            }
        },
        error: function (xhr, status) {
            console.log("Error on getting feeders.");
        }
    });

    setTimeout(load_feeders, 1750);
}

$('#select_operation').on('change', function () {
    let operation = this.value;

    switch (operation) {
        case "Add feeder":
            add_feeder();
            break;
        case "Delete feeder":
            delete_feeder();
            break;
        case "Update feeder":
            update_feeder();
            break;
    }
});

$('#send_operation').on('click', function () {
    $('#foo').toggleClass('active');
    let operation = $('#select_operation').val();

    switch (operation) {
        case "Add feeder":
            send_add_feeder();
            break;
        case "Delete feeder":
            send_delete_feeder();
            break;
        case "Update feeder":
            send_update_feeder();
            break;
    }
});

//Add feeder
function add_feeder() {
    $('#operation_form').html('');

    $('#operation_form').append(
        "<div id='fr_inp'><input type='text' class='form-control' id='serial' placeholder='Feeder serial number' value=''></div>"
    );

    $('#btn_toggle').show();
}

function send_add_feeder() {

    get_configs();

    let serial = $('#serial').val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/add_feeder",
        data: {
            "username": username_conf,
            "token": token_conf,
            "serial": serial
        },
        success: function (msg) {
            console.log(msg)
            initial_load_feeders();
            selector.selectedIndex = 0;
            $('#operation_form').html('');
            $('#btn_toggle').hide();
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
}

//Update feeder
function update_feeder() {
    $('#operation_form').html('');

    get_configs()

    let options = "";

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        data: {
            "token": token_conf,
            "username": username_conf
        },
        url: "/get_feeders",
        success: function (msg) {
            for (var i = 0; i < msg.response.length; i++) {
                options = options + '<option>' + 'ID:' + msg.response[i].id + '| Serial: ' + msg.response[i].serial + '</option>';
            }

            $('#operation_form').append(
                "<div id='fr_inp'><select class='form-control' id='select_feeder'><option value='' disabled selected>Select feeder to update</option>" + options + "</select></div>" +
                "<div id='fr_inp'><input type='text' class='form-control' id='serial' placeholder='New serial' value=''></div>"
            );

            $('#btn_toggle').show();
        },
        error: function (xhr, status) {
            console.log("Error on getting feeders.");
        }
    });
}

function send_update_feeder() {
    get_configs();

    let serial = $('#serial').val();
    let feeder = $('#select_feeder').val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/update_feeder",
        data: {
            "username": username_conf,
            "token": token_conf,
            "serial": serial,
            "feeder": feeder
        },
        success: function (msg) {
            console.log(msg)
            selector.selectedIndex = 0;
            $('#operation_form').html('');
            $('#btn_toggle').hide();
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
}

//Delete feeder
function delete_feeder() {
    console.log("Enters");
    $('#operation_form').html('');

    get_configs()

    let options = "";

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        data: {
            "token": token_conf,
            "username": username_conf
        },
        url: "/get_feeders",
        success: function (msg) {
            for (var i = 0; i < msg.response.length; i++) {
                options = options + '<option>' + 'ID:' + msg.response[i].id + '| Serial: ' + msg.response[i].serial + '</option>';
            }

            $('#operation_form').append(
                "<div id='fr_inp'><select class='form-control' id='select_feeder'><option value='' disabled selected>Select feeder to delete</option>" + options + "</select></div>"
            );

            $('#btn_toggle').show();
        },
        error: function (xhr, status) {
            console.log("Error on getting feeders.");
        }
    });
}

function send_delete_feeder() {
    get_configs();

    let feeder = $('#select_feeder').val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/delete_feeder",
        data: {
            "username": username_conf,
            "token": token_conf,
            "feeder": feeder
        },
        success: function (msg) {
            console.log(msg)
            selector.selectedIndex = 0;
            initial_load_feeders();
            $('#operation_form').html('');
            $('#btn_toggle').hide();
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
}

$('#display_feeders').on('click', '#fill_water', function (e) {
    console.log("FILL WATER STARTED");
    let serial = $(this).data('feeder_serial');
    console.log(serial);
    channel.push(serial + "_agent", "fill_water")
});

$('#display_feeders').on('click', '#fill_food', function (e) {
    console.log("FILL WATER STARTED");
    let serial = $(this).data('feeder_serial');
    console.log(serial);
    channel.push(serial + "_agent", "fill_food")
});