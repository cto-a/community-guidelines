require 'ctoa'
require 'erb'

class CTOA::Util
  def self.render_text(template, b)
    ERB.new(template).result(b)
  end
end
