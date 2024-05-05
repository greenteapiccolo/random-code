const sleep = (ms) => {
  return new Promise((resolve, reject) => setTimeout(resolve, ms));
};

const likeAllPlaylistSongs = async () => {
  const notLikedSongElements = document.querySelectorAll(
    '.like[aria-pressed="false"]'
  );
  const notLikedSongElementsReversed = Array.from(elements).reverse();

  for (let i = 0; i < notLikedSongElementsReversed.length; i++) {
    await sleep(1000);
    notLikedSongElementsReversed[i].click();
  }
};

likeAllPlaylistSongs();
