import consumer from "./consumer";

consumer.subscriptions.create("DashboardNotificationRemoveChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connected");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("disconnected");
  },

  received(notification_id) {
    // Called when there's incoming data on the websocket for this channel
    $(`#notification-${notification_id}`).remove();
    const notificationList = $(`[id^=notification]`).toArray();
    if (!notificationList.length) {
      $(".no-notification").show();
      $(".notification-alert").hide();
    }
  },
});
