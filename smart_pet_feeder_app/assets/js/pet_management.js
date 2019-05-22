
let csrf = document.querySelector("meta[name=csrf]").content;

let username_conf = "";
let token_conf = "";

let selector = document.getElementById('select_operation_pet');

function get_configs() {
    username_conf = $('#username_conf').val();
    token_conf = $('#token_conf').val();
}

$(document).ready(function () {
    // $('#btn_toggle').hide();
    load_pets();
});

function load_pets() {

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
        url: "/get_pets",
        success: function (msg) {
            console.log(msg)

            if (msg.response.length == 0) {
                $('#display_pets').html(
                    "<div id='no_pets'><label>You have no pets added.</label></div>"
                );
            }
            else {
                let pets = "";
                for (let i = 0; i < msg.response.length; i++) {

                    pets = pets +
                        "<div class='pet_box' id='pet_id_" + msg.response[i].id + "'>" +
                        "<label>Name: " + msg.response[i].name + "</label>" +
                        "<label>Age: " + msg.response[i].age + "</label>" +
                        "<label>Type: " + msg.response[i].type + "</label>" +
                        "<label>Gender: " + msg.response[i].gender + "</label>" +
                        "<label>Breed: " + msg.response[i].breed + "</label>" +
                        "</div>"
                }

                $('#display_pets').html(
                    pets
                );
            }
        },
        error: function (xhr, status) {
            console.log("Error on getting pets.");
        }
    });

}

$('#select_operation_pet').on('change', function () {
    let operation = this.value;

    switch (operation) {
        case "Add pet":
            add_pet();
            break;
        case "Delete pet":
            delete_pet();
            break;
        case "Update pet":
            update_pet();
            break;
    }
});

$('#send_operation_pet').on('click', function () {
    $('#foo').toggleClass('active');
    let operation = $('#select_operation_pet').val();

    switch (operation) {
        case "Add pet":
            send_add_pet();
            break;
        case "Delete pet":
            send_delete_pet();
            break;
        case "Update pet":
            send_update_pet();
            break;
    }
});

//Add pet
function add_pet() {
    $('#operation_form_pet').html('');

    $('#operation_form_pet').append(
        "<div id='fr_inp'><input type='text' class='form-control' id='name' placeholder='Pet name' value=''></div>" +
        "<div id='fr_inp'><input type='number' class='form-control' id='age' placeholder='Pet age' value=''></div>" +
        "<div id='fr_inp'><select class='form-control' id='type' ><option value='' disabled selected>Select pet type</option><option>Dog</option><option>Cat</option></select></div>" +
        "<div id='fr_inp'><select class='form-control' id='gender' ><option value='' disabled selected>Select pet gender</option><option>Male</option><option>Female</option></select></div>" +
        "<div id='fr_inp'><input type='text' class='form-control' id='breed' placeholder='Pet breed' value=''></div>"
    );

    $('#btn_toggle').show();
}

function send_add_pet() {

    get_configs();

    let name = $('#name').val();
    let age = $('#age').val();
    let type = $('#type').val();
    let gender = $('#gender').val();
    let breed = $('#breed').val();

    console.log(name, age, type, gender, breed);

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/add_pet",
        data: {
            "username": username_conf,
            "token": token_conf,
            "name": name,
            "age": age,
            "type": type,
            "gender": gender,
            "breed": breed
        },
        success: function (msg) {
            console.log(msg)
            load_pets();
            selector.selectedIndex = 0;
            $('#operation_form_pet').html('');
            $('#btn_toggle').hide();
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
}

//Update pet
function update_pet() {
    $('#operation_form_pet').html('');

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
        url: "/get_pets",
        success: function (msg) {
            for (var i = 0; i < msg.response.length; i++) {
                options = options + '<option>' + 'ID:' + msg.response[i].id + '| Name: ' + msg.response[i].name + '</option>';
            }

            $('#operation_form_pet').append(
                "<div id='fr_inp'><select class='form-control' id='select_pet'><option value='' disabled selected>Select pet to update</option>" + options + "</select></div>" +
                "<div id='fr_inp'><input type='text' class='form-control' id='name' placeholder='Pet name' value=''></div>" +
                "<div id='fr_inp'><input type='number' class='form-control' id='age' placeholder='Pet age' value=''></div>" +
                "<div id='fr_inp'><select class='form-control' id='type' ><option value='' disabled selected>Select pet type</option><option>Dog</option><option>Cat</option></select></div>" +
                "<div id='fr_inp'><select class='form-control' id='gender' ><option value='' disabled selected>Select pet gender</option><option>Male</option><option>Female</option></select></div>" +
                "<div id='fr_inp'><input type='text' class='form-control' id='breed' placeholder='Pet breed' value=''></div>"
            );

            $('#btn_toggle').show();
        },
        error: function (xhr, status) {
            console.log("Error on getting pets.");
        }
    });
}

function send_update_pet() {
    get_configs();

    let pet = $('#select_pet').val();

    let name = $('#name').val();
    let age = $('#age').val();
    let type = $('#type').val();
    let gender = $('#gender').val();
    let breed = $('#breed').val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/update_pet",
        data: {
            "username": username_conf,
            "token": token_conf,
            "pet": pet,
            "name": name,
            "age": age,
            "type": type,
            "gender": gender,
            "breed": breed
        },
        success: function (msg) {
            console.log(msg)
            selector.selectedIndex = 0;
            load_pets();
            $('#operation_form_pet').html('');
            $('#btn_toggle').hide();
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
}

//Delete pet
function delete_pet() {
    $('#operation_form_pet').html('');

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
        url: "/get_pets",
        success: function (msg) {
            for (var i = 0; i < msg.response.length; i++) {
                options = options + '<option>' + 'ID:' + msg.response[i].id + '| Name: ' + msg.response[i].name + '</option>';
            }

            $('#operation_form_pet').append(
                "<div id='fr_inp'><select class='form-control' id='select_pet'><option value='' disabled selected>Select pet to delete</option>" + options + "</select></div>"
            );

            $('#btn_toggle').show();
        },
        error: function (xhr, status) {
            console.log("Error on getting pets.");
        }
    });
}

function send_delete_pet() {
    get_configs();

    let pet = $('#select_pet').val();

    $.ajax({
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": csrf
        },
        url: "/delete_pet",
        data: {
            "username": username_conf,
            "token": token_conf,
            "pet": pet
        },
        success: function (msg) {
            console.log(msg)
            selector.selectedIndex = 0;
            load_pets();
            $('#operation_form_pet').html('');
            $('#btn_toggle').hide();
        },
        error: function (xhr, status) {
            console.log("Error!")
        }
    });
}