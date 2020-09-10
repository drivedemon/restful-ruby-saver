function generateRandomPassword() {
  var randomstring = Math.random().toString(36).slice(-12);
  $("#txtPassword").val(randomstring);
  $("#txtConfirmPassword").val(randomstring);
  checkPasswordMatch();
}

$(document).on("turbolinks:load ready", function () {
  $("#generate-password-btn").click(generateRandomPassword);
});
