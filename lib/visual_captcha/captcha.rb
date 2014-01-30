require 'json'
require 'securerandom'

class VisualCaptcha::Captcha
  def initialize(session, assets_path = nil, default_images = nil, default_audios = nil)
    @session = session

    @assets_path = assets_path
    @assets_path ||= File.join VisualCaptcha.root, 'assets'

    @image_options = default_images
    @image_options ||= JSON.load File.read("#{@assets_path}/images.json")

    @audio_options = default_audios
    @audio_options ||= JSON.load File.read("#{@assets_path}/audios.json")
  end

  def generate(number_of_options = 5)
    @session.clear

    number_of_options = number_of_options.to_i
    number_of_options = 2 if number_of_options < 2

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

    File.read file_path
  end
end