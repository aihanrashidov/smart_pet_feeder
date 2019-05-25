
import { Socket } from "phoenix"
import Swal from 'sweetalert2'

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
            console.log("GET FEEDERS FROM DB: " + msg)

            if (msg.response.length == 0) {
                $('#display_feeders').html(
                    "<div id='no_feeders'><label>You have no feeders added.</label></div>"
                );
            }
            else {
                let feeders = "";
                for (let i = 0; i < msg.response.length; i++) {

                    channel.on(msg.response[i].serial + "_operation_app", msg => {
                        console.log("Got operation finish message from agent: " + msg.message.serial, msg)
                        $('#loading').toggleClass('active');
                    }
                    )

                    channel.on(msg.response[i].serial + "_app", msg => {
                        console.log("Got message from agent: " + msg.message.serial, msg)
                        let top_water_sensor = msg.message.sensors_data.top_water_sensor
                        let bottom_water_sensor = msg.message.sensors_data.bottom_water_sensor;
                        let feeder_id = msg.message.feeder_id;

                        if (top_water_sensor == "YES") {
                            $('#loading').toggleClass('active');
                        }

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
                                "feeder": feeder_id,
                                "device_status": "Active"
                            },
                            success: function (msg) {
                                console.log("UPDATE FEEDER STATUS: " + msg)
                            },
                            error: function (xhr, status) {
                                console.log("Error!")
                            }
                        });

                    }
                    )

                    let device_status = "";

                    if (msg.response[i].device_status == "Active") {
                        device_status = "<label style='color: green;'>Active</label>";

                        if (msg.response[i].water_status == "No water") {
                            water_btn_status = "enabled";
                        }
                        else {
                            water_btn_status = "disabled";
                        }

                    } else {
                        device_status = "<label style='color: red;'>Inactive</label>";
                        water_btn_status = "disabled";
                        food_btn_status = "disabled";
                    }

                    feeders = feeders +
                        "<div class='feeder_box' id='feeder_id_" + msg.response[i].id + "'>" +
                        "<label>Serial number: " + msg.response[i].serial + "</label>" +
                        "<label>Location: " + msg.response[i].location + "</label>" +
                        "<label>Device status: " + device_status + "</label>" +
                        "<label>Water status: " + msg.response[i].water_status + "</label>" +
                        "<button id='fill_water' class='btn btn-dark' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + water_btn_status + ">Fill Water</button>" +
                        "<br>" +
                        "<button id='fill_food' class='btn btn-dark' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + food_btn_status + ">Fill Food</button>" +
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
            console.log("GET FEEDERS FROM DB: " + msg)

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

                    let device_status = "";

                    if (msg.response[i].device_status == "Active") {
                        device_status = "<label style='color: green;'>Active</label>";

                        if (msg.response[i].water_status == "No water") {
                            water_btn_status = "enabled";
                        }
                        else {
                            water_btn_status = "disabled";
                        }

                    } else {
                        device_status = "<label style='color: red;'>Inactive</label>";
                        water_btn_status = "disabled";
                        food_btn_status = "disabled";
                    }

                    feeders = feeders +
                        "<div class='feeder_box' id='feeder_id_" + msg.response[i].id + "'>" +
                        "<label>Serial number: " + msg.response[i].serial + "</label>" +
                        "<label>Location: " + msg.response[i].location + "</label>" +
                        "<label>Device status: " + device_status + "</label>" +
                        "<label>Water status: " + msg.response[i].water_status + "</label>" +
                        "<button id='fill_water' class='btn btn-dark' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + water_btn_status + ">Fill Water</button>" +
                        "<br>" +
                        "<button id='fill_food' class='btn btn-dark' data-feeder_serial='" + msg.response[i].serial + "' feeder_id='" + msg.response[i].id + "' " + food_btn_status + ">Fill Food</button>" +
                        "</div>";

                    $.ajax({
                        method: "POST",
                        headers: {
                            "X-CSRF-TOKEN": csrf
                        },
                        url: "/update_feeder_dev_status",
                        data: {
                            "username": username_conf,
                            "token": token_conf,
                            "feeder": msg.response[i].id,
                            "device_status": "Inactive"
                        },
                        success: function (msg) {
                            console.log("UPDATE FEEDER STATUS: " + msg)
                        },
                        error: function (xhr, status) {
                            console.log("Error!")
                        }
                    });
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

    setTimeout(load_feeders, 3000);
}

$('#select_operation').on('change', function () {
    let operation = this.value;
    $('#invalid').html('');

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
        "<div id='fr_inp'><input type='text' class='form-control' id='serial' placeholder='Feeder serial number' value=''></div>" +
        "<div id='fr_inp'><input type='text' class='form-control' id='location' placeholder='Feeder location' value=''></div>"
    );

    $('#btn_toggle').show();
}

function send_add_feeder() {

    get_configs();

    let serial = $('#serial').val();
    let location = $('#location').val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/add_feeder",
        data: {
            "username": username_conf,
            "token": token_conf,
            "serial": serial,
            "location": location
        },
        success: function (msg) {
            console.log(msg)

            if (msg.response == "new_serial") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing serial number.</label></div>"
                );
            }
            else if (msg.response == "location") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing location.</label></div>"
                );
            }
            else if (msg.response == "both") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing serial number and location.</label></div>"
                );
            }
            else {
                if (msg.response == "no_such_serial") {
                    Swal.fire(
                        'Error!',
                        'There is no device with such serial number.',
                        'error'
                    )
                }

                initial_load_feeders();

                selector.selectedIndex = 0;
                $('#invalid').html('');
                $('#operation_form').html('');
                $('#btn_toggle').hide();
            }


        },
        error: function (xhr, status) {
            $('#invalid').html('');
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
                "<div id='fr_inp'><input type='text' class='form-control' id='location' placeholder='New location' value=''></div>"
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

    let location = $('#location').val();
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
            "location": location,
            "feeder": feeder
        },
        success: function (msg) {
            console.log(msg)

            if (msg.response == "feeder") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing feeder.</label></div>"
                );
            }
            else if (msg.response == "location") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing location.</label></div>"
                );
            }
            else if (msg.response == "both") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing feeder and location.</label></div>"
                );
            }
            else {
                selector.selectedIndex = 0;
                $('#invalid').html('');
                $('#operation_form').html('');
                $('#btn_toggle').hide();
            }


        },
        error: function (xhr, status) {
            $('#invalid').html('');
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
            if (msg.response == "feeder") {
                $('#invalid').html('');
                $('#invalid').append(
                    "<div id='invalids'><label>&#8226;</label><label id='inv_text'>Missing feeder.</label></div>"
                );
            }
            else {
                selector.selectedIndex = 0;
                $('#invalid').html('');
                $('#operation_form').html('');
                $('#btn_toggle').hide();
            }


        },
        error: function (xhr, status) {
            $('#invalid').html('');
            console.log("Error!")
        }
    });
}

$('#display_feeders').on('click', '#fill_water', function (e) {
    console.log("FILL WATER STARTED");
    let serial = $(this).data('feeder_serial');
    console.log(serial);
    channel.push(serial + "_agent", "fill_water");
    $('#loading').toggleClass('active');
});

$('#display_feeders').on('click', '#fill_food', function (e) {
    console.log("FILL FOOD STARTED");
    let serial = $(this).data('feeder_serial');
    console.log(serial);

    Swal.fire({
        title: 'Select Portions',
        input: 'select',
        inputOptions: {
            1: '1',
            2: '2',
            3: '3',
            4: '4',
            5: '5'
        },
        inputPlaceholder: 'Portions',
        showCancelButton: true,
        inputValidator: (value) => {
            return new Promise((resolve) => {
                if (value) {
                    resolve()
                } else {
                    resolve('You have to select a portion.')
                }
            })
        }
    }).then((result) => {
        if (result.value) {
            let portions = parseInt(result.value);
            $('#loading').toggleClass('active');
            channel.push(serial + "_agent", { "message": "fill_food", "portions": portions });
        }
    });
});