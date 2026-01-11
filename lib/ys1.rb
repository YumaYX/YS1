# frozen_string_literal: true

# YS1
module YS1; end

Dir.glob(File.join(__dir__, "ys1", "**", "*.rb")).each do |file|
  require(file)
end
