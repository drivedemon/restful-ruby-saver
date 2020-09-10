function readImageURL(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (e) {
      $("#avatarDisplay").attr("src", "");
      $("#avatarDisplay").attr("src", e.target.result);
    };

    reader.readAsDataURL(input.files[0]); // convert to base64 string
  }
}

$(document).on("turbolinks:load ready", function () {
  $("#imgInput").change(function () {
    readImageURL(this);
  });
});
