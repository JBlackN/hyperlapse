> CURRENTLY **UNUSABLE** DUE TO GOOGLE'S [PRICING AND BILLING CHANGES](https://cloud.google.com/maps-platform/user-guide/pricing-changes/).

# Hyperlapse

[Hyperlapse](https://en.wikipedia.org/wiki/Hyperlapse) video generator for Google Maps routes using Google StreetView.

## Dependencies

- [ImageMagick](https://www.imagemagick.org/script/index.php)
- [FFmpeg](https://www.ffmpeg.org/)

## Local installation

```bash
bundle install
gem build hyperlapse.gemspec
gem install hyperlapse-0.1.0.gem
```

## Usage

```bash
hyperlapse help

hyperlapse config --api-key GOOGLE_API_KEY
hyperlapse init GOOGLE_MAPS_KML_FILE
hyperlapse config
hyperlapse download
hyperlapse generate
```
