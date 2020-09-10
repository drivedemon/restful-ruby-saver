window.rating = () => {
  return {
    getRatingStar(rating) {
      const starList = [1, 2, 3, 4, 5].map((i) => {
        const star = i <= rating ? '⭑' : '⭒';
        return `<span class="text-yellow mr-1" style="font-size: 25px">${star}</span>`;
      });
      return starList.join('');
    },
  };
};
