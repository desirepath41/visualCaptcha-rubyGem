require 'visual_captcha/version'
require 'visual_captcha/session'
require 'visual_captcha/captcha'

module VisualCaptcha
  def self.root
    File.expand_path '../..', __FILE__
  end
end