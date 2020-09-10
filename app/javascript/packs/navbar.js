$(document).on('turbolinks:load ready', function () {
  const notificationList = $(`[id^=notification]`).toArray();
  notificationList.length ? $('.no-notification').hide() : $('.no-notification').show();
  notificationList.length ? $('.notification-alert').show() : $('.notification-alert').hide();
});

window.navbar = () => {
  return {
    checkActiveUrl(urlList) {
      const activeUrl = window.location.href;
      let isMatch = false;

      urlList.map((url) => {
        if (activeUrl.includes(url)) {
          isMatch = true;
        }
      });

      return isMatch;
    }
  };
};
