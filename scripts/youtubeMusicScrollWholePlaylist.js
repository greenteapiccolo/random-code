const sleep = (ms) => {
  return new Promise((resolve, reject) => setTimeout(resolve, ms));
};

const getNumberOfDisplayedPlaylistSongs = () =>
  document.getElementsByTagName("ytmusic-responsive-list-item-renderer").length;

const scrollToPlaylistShelfBottom = () => {
  const playlistShelfElement = document.getElementsByTagName(
    "ytmusic-shelf-renderer"
  )[0];
  window.scrollTo(0, playlistShelfElement.scrollHeight);
};

const scrollWholePlaylist = async (numberOfPlaylistSongs) => {
  let numberOfDisplayedPlaylistSongs = getNumberOfDisplayedPlaylistSongs();
  while (numberOfDisplayedPlaylistSongs < numberOfPlaylistSongs) {
    scrollToPlaylistShelfBottom();
    console.info("Waiting 3 seconds until new scrolling..");
    await sleep(3000);
    numberOfDisplayedPlaylistSongs = getNumberOfDisplayedPlaylistSongs();
  }
  scrollToPlaylistShelfBottom();
};

const main = async (numberOfPlaylistSongs) => {
  window.scrollTo(0, document.body.scrollHeight);
  await sleep(3000);
  console.info("Starting scrolling..");
  scrollWholePlaylist(numberOfPlaylistSongs);
};

main();
