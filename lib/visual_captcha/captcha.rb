require 'json'
require 'securerandom'

class VisualCaptcha::Captcha
  # @param session is the default session object
  # @param assets_path is optional. Defaults to 'assets'. The path is relative to /
  # @param default_images is optional. Defaults to the array inside ./images.json. The path is relative to ./images/
  # @param default_audios is optional. Defaults to the array inside ./audios.json. The path is relative to ./audios/
  def initialize(session, assets_path = nil, default_images = nil, default_audios = nil)
    @session = session

    @assets_path = assets_path
    @assets_path ||= File.join VisualCaptcha.root, 'assets'

    @image_options = default_images
    @image_options ||= JSON.load File.read("#{@assets_path}/images.json")

    @audio_options = default_audios
    @audio_options ||= JSON.load File.read("#{@assets_path}/audios.json")
  end

  # Generate a new valid option
  # @param numberOfOptions is optional. Defaults to 5
  def generate(number_of_options = 5)
    @session.clear

    number_of_options = number_of_options.to_i
    number_of_options = 4 if number_of_options < 4

    images = all_image_options.sample number_of_options
    images.each do |image|
      image['value'] = SecureRandom.hex 10
    end

    @session.set 'images', images

    @session.set 'validImageOption', selected_images.sample

    @session.set 'validAudioOption', all_audio_options.sample

    @session.set 'frontendData', {
        'values' => selected_images.map { |i| i['value'] },
        'imageName' => valid_image_option['name'],
        'imageFieldName' => SecureRandom.hex(10),
        'audioFieldName' => SecureRandom.hex(10)
    }
  end

  # Stream audio file
  # @param headers object. used to store http headers for streaming
  # @param fileType defaults to 'mp3', can also be 'ogg'
  def stream_audio(headers, file_type = 'mp3')
    audio_option = valid_audio_option
    return nil if audio_option.nil?

    audio_file_name = "#{audio_option['path']}"
    audio_file_path = "#{@assets_path}/audios/#{audio_file_name}"

    if file_type == 'ogg'
      audio_file_path.gsub! /\.mp3/i, '.ogg'

      content_type = 'application/ogg'
    else
      content_type = 'audio/mpeg'
    end

    read_file headers, audio_file_path, content_type
  end

  # Stream image file given an index in the session visualCaptcha images array
  # @param headers object. used to store http headers for streaming
  # @param index of the image in the session images array to send
  # @paran isRetina boolean. Defaults to false
  def stream_image(headers, index, is_retina)
    image_option = selected_image_at_index index.to_i
    return nil if image_option.nil?

    image_file_name = "#{image_option['path']}"
    image_file_name.gsub! /\.png/i, '@2x.png' if (is_retina.to_i >= 1)
    image_file_path = "#{@assets_path}/images/#{image_file_name}"

    read_file headers, image_file_path, 'image/png'
  end

  def selected_images
    @session.get 'images'
  end

  def selected_image_at_index(index)
    images = selected_images
    images[index] unless images.nil?
  end

  def frontend_data
    @session.get 'frontendData'
  end

  def valid_image_option
    @session.get 'validImageOption'
  end

  def valid_audio_option
    @session.get 'validAudioOption'
  end

  def validate_image(sent_option)
    sent_option == valid_image_option['value']
  end

  def validate_audio(sent_option)
    sent_option == valid_audio_option['value']
  end

  def all_image_options
    @image_options
  end

  def all_audio_options
    @audio_options
  end

  private

  def read_file(headers, file_path, content_type)
    return nil unless File.exists? file_path

    headers['Content-Type'] = content_type
    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    headers['Pragma'] = 'no-cache'
    headers['Expires'] = '0'

    file_contents = File.read file_path

    # Add some noise randomly, so images can't be saved and matched easily by filesize or checksum
    file_contents += SecureRandom.hex(SecureRandom.random_number(1500))

    return file_contents
  end
end