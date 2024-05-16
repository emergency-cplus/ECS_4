import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["url", "preview"];

  connect() {
    this.urlTarget.addEventListener("input", () => this.updatePreview());
  }

  updatePreview() {
    const url = this.urlTarget.value;
    const videoId = this.extractVideoId(url);

    if (videoId) {
      this.previewTarget.innerHTML = this.createVideoIframe(videoId);
    } else {
      this.previewTarget.innerHTML = "";
    }
  }

  extractVideoId(url) {
    if (url.includes('youtube.com/shorts/')) {
      const videoId = url.split('youtube.com/shorts/')[1].split('?')[0];
      return videoId;
    }
    return null;
  }

  createVideoIframe(videoId) {
    return `
      <iframe
        width="360"
        height="640"
        src="https://www.youtube.com/embed/${videoId}"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen>
      </iframe>
    `;
  }
}
