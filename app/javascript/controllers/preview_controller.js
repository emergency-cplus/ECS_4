// app/javascript/controllers/preview_controller.js

import { Controller } from "stimulus";
import { extractShortsVideoId, createShortsVideoIframe } from "../utils/shorts_utils";

export default class extends Controller {
  static targets = ["url", "preview"];

  connect() {
    this.updatePreview();
  }

  updatePreview() {
    const url = this.urlTarget.value;
    const videoId = extractShortsVideoId(url);
    if (videoId) {
      this.previewTarget.innerHTML = createShortsVideoIframe(videoId);
    } else {
      this.previewTarget.innerHTML = "Invalid YouTube Shorts URL";
    }
  }
}
