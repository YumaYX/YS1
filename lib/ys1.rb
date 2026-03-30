# frozen_string_literal: true

# YS1
module YS1; end

[
  "*.rb",
  "core_ext/*.rb"
].each do |glob_name|
  Dir.glob("#{__dir__}/ys1/#{glob_name}").each do |lib|
    require(lib)
  end
end
