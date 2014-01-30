require 'spec_helper'

describe VisualCaptcha::Captcha do
  before do
    @session = VisualCaptcha::Session.new({})
  end

  it "should generate valid data" do
    captcha = VisualCaptcha::Captcha.new(@session)
    captcha.generate
  end
end