[![Build Status](https://travis-ci.org/emotionLoop/visualCaptcha-rubyGem.svg?flat=true&branch=master)](https://travis-ci.org/emotionLoop/visualCaptcha-rubyGem)
[![Codacy](https://www.codacy.com/project/badge/4d1f731df8ea4dfe99b51032f92fc371)](https://www.codacy.com/app/bruno-bernardino/visualCaptcha-rubyGem)
[![Code Climate](https://codeclimate.com/github/emotionLoop/visualCaptcha-rubyGem/badges/gpa.svg)](https://codeclimate.com/github/emotionLoop/visualCaptcha-rubyGem)

# visualCaptcha-rubyGem

RubyGem package for visualCaptcha's backend service


## Installation with Gem

You need Ruby 1.9.3+ installed.
```
gem install visual_captcha
```

## Run tests

You need Bundler and Rake installed and then you can run
```
bundle install && rake
```


## Usage

### Initialization

You have to initialize a session for visualCaptcha to inject the data it needs. You'll need this variable to start and verify visualCaptcha as well.

```
@session = VisualCaptcha::Session.new session, @namespace
```
Where:

- `@namespace` is optional. It's a string and defaults to 'visualcaptcha'. You'll need to specifically set this if you're using more than one visualCaptcha instance in the same page, so the code can identify from which one is the validation coming from.


### Setting Routes for the front-end

You also need to set routes for `/start/:howmany`, `/image/:index`, and `/audio/:type`. These will usually look like:

```ruby
get '/start/:how_many' do
    captcha = VisualCaptcha::Captcha.new @session
    captcha.generate params[:how_many]

    json captcha.frontend_data
  end

  get '/audio/?:type?' do
    type = params[:type]
    type = 'mp3' if type != 'ogg'

    captcha = VisualCaptcha::Captcha.new @session

    if (@body = captcha.stream_audio @headers, type)
      body @body
    else
      not_found
    end
  end

  get '/image/:index' do
    captcha = VisualCaptcha::Captcha.new @session

    if (@body = captcha.stream_image @headers, params[:index], params[:retina])
      body @body
    else
      not_found
    end
  end
```

### Validating the image/audio

Here's how it'll usually look:

```ruby
@session = VisualCaptcha::Session.new session
captcha = VisualCaptcha::Captcha.new @session
frontend_data = captcha.frontend_data()

# If an image field name was submitted, try to validate it
if ( image_answer = params[ frontend_data[ 'imageFieldName' ] ] )
  if captcha.validate_image image_answer
    # Image was valid.
  else
    # Image was submitted, but wrong.
  end
elsif ( audio_answer = params[ frontend_data[ 'audioFieldName' ] ] )
  if captcha.validate_audio audio_answer.downcase
    # Audio answer was valid.
  else
    # Audio was submitted, but wrong.
  end
else
  # Apparently no fields were submitted, so the captcha wasn't filled.
end
```

### VisualCaptcha::Session properties

- `:session`, Object — The object that will hold the session data for visualCaptcha.
- `:namespace`, String — This is private and will hold the namespace for each visualCaptcha instance. Defaults to 'visualcaptcha'.

### VisualCaptcha::Session methods

- `initialize( :session, :namespace )` — Initialize the visualCaptcha session.
- `clear()` — Will clear the session for the current namespace.
- `get( :key )` — Will return a value for the session's `:key`.
- `set( :key, :value )` — Set the `:value` for the session's `:key`.


### VisualCaptcha::Captcha properties

- `@session`, Object that will have a reference for the session object.
  It will have .visualCaptcha.images, .visualCaptcha.audios, .visualCaptcha.validImageOption, and .visualCaptcha.validAudioOption.
- `@assets_path`, Assets path. By default, it will be './assets'
- `@image_options`, All the image options.
  These can be easily overwritten or extended using addImageOptions( <Array> ), or replaceImageOptions( <Array> ). By default, they're populated using the ./images.json file
- `@audio_options`, All the audio options.
  These can be easily overwritten or extended using addAudioOptions( <Array> ), or replaceAudioOptions( <Array> ). By default, they're populated using the ./audios.json file

### VisualCaptcha::Captcha methods

You'll find more documentation on the code itself, but here's the simple list for reference.

- `initialize(session, assets_path = nil, default_images = nil, default_audios = nil)` — Initialize the visualCaptcha object.
- `generate(number_of_options = 5)` — Will generate a new valid option, within a `:numberOfOptions`.
- `stream_audio(headers, file_type = 'mp3')` — Stream audio file.
- `stream_image(headers, index, is_retina)` — Stream image file given an index in the session visualCaptcha images array.
- `frontend_data()` — Get data to be used by the frontend.
- `valid_image_option()` — Get the current validImageOption.
- `valid_audio_option()` — Get the current validAudioOption.
- `validate_image( sent_option )` — Validate the sent image value with the validImageOption.
- `validate_audio( sent_option )` — Validate the sent audio value with the validAudioOption.
- `selected_images()` — Return generated image options.
- `getAudioOption()` — Alias for getValidAudioOption.
- `all_image_options()` — Return all the image options.
- `all_audio_options()` — Return all the audio options.


## License

MIT. Check the [LICENSE](LICENSE) file.