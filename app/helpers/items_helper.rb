module ItemsHelper
    def get_youtube_video_id(url)
      if url.include?('youtube.com/shorts/')
        video_id = url.split('youtube.com/shorts/')[1].split('?')[0]
        return video_id
      end
      nil
    end
  end
  