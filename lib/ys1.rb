# frozen_string_literal: true

# YS1
module YS1; end

# all auto load
Dir.glob(File.join(__dir__, "ys1", "**", "*.rb")).each do |file|
  require(file)
end
