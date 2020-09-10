window.checkPasswordMatch = function () {
  var password = $("#txtPassword").val();
  var confirmPassword = $("#txtConfirmPassword").val();

  if (password != confirmPassword) {
    document.getElementById("passwordChecker").style.display = "block";
    $("#submit-user-form").attr("disabled", "disabled");
  } else {
    document.getElementById("passwordChecker").style.display = "none";
    $("#submit-user-form").removeAttr("disabled");
  }
};

$(document).on("turbolinks:load ready", function () {
  $("#txtPassword, #txtConfirmPassword").keyup(checkPasswordMatch);
});
