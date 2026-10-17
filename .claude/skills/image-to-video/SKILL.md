---
name: image-to-video
description: Turn an attached photo into a short MP4 clip (camera motion over the still image) for social media or the website. Use when the user runs /image-to-video or asks to make a video from a photo.
---

# Image to video

Creates a short video from a still photo with ffmpeg by moving a virtual camera over it.
The subject does not actually move; this is not AI-generated motion.

## Steps

1. Find the image: use the attached upload path, or a path the user gives.
2. Pick the style from the user's arguments (default `reel`):
   - `reel` — 1080x1920 (9:16), 5.5s: slow drift, then a snap zoom with a decaying shake. For Reels/TikTok/Shorts.
   - `pushin` — 1080x1440 (3:4), 6s: slow, smooth push-in with fades.
3. Look at the image and choose the focus point: the action (e.g. glove hitting the bag),
   as fractions of width and height. Keep faces inside the final frame — at 9:16 and 1.4x zoom
   the visible width is only about 40% of the image, so bias the point toward the person.
4. Render into the scratchpad directory:
   ```
   bash .claude/skills/image-to-video/render.sh <image> <scratchpad>/<name>.mp4 <style> <fx> <fy>
   ```
5. Check framing: extract frames at the start, middle and end
   (`ffmpeg -ss <t> -i out.mp4 -frames:v 1 -vf scale=360:-1 f.jpg`, then `hstack` them) and view them.
   If heads or the key action are cropped, adjust fx/fy and re-render.
6. Send the MP4 to the user with SendUserFile. Don't commit videos to the repo unless asked.
