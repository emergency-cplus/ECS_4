// app/javascript/utils/shorts_utils.js

export function extractShortsVideoId(url) {
    if (url.includes('youtube.com/shorts/')) {
      const videoId = url.split('youtube.com/shorts/')[1].split('?')[0];
      return videoId;
    }
    return null;
  }
  
  export function createShortsVideoIframe(videoId) {
    return `
      <iframe width="360" height="640" src="https://www.youtube.com/embed/${videoId}" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    `;
  }
  