window.tabMenu = () => {
  return {
    checkActiveMenu(menuName) {
      const activeURL = document.location.href;
      return activeURL.includes(menuName);
    },
  };
};
