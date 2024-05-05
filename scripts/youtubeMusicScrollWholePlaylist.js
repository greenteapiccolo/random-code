const getNumberOfDisplayedPlaylistSongs = () =>
  document.getElementsByTagName("ytmusic-responsive-list-item-renderer").length;

const scrollToPlaylistShelfBottom = ()=> {
    const playlistShelfElement = document.getElementsByTagName('ytmusic-shelf-renderer')[0]
    window.scrollTo(0, playlistShelfElement.scrollHeight)
}

const scrollWholePlaylist = (numberOfPlaylistSongs) => {
    let numberOfDisplayedPlaylistSongs = getNumberOfDisplayedPlaylistSongs()

    const loop = setInterval(() => {
        if(numberOfDisplayedPlaylistSongs >= numberOfPlaylistSongs){
            scrollToPlaylistShelfBottom();
        }
        numberOfDisplayedPlaylistSongs = getNumberOfDisplayedPlaylistSongs()
        scrollToPlaylistShelfBottom();
        console.info("Waiting 3 seconds until new scrolling..");
    },3000)
}

const main = (numberOfPlaylistSongs) => {
    window.scrollTo(0, document.body.scrollHeight);
    setTimeout(() => {
        console.info('Starting scrolling..')
    scrollWholePlaylist(numberOfPlaylistSongs)
      }, 3000);
}

//main()
