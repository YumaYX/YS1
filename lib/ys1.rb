# frozen_string_literal: true

# YS1
module YS1; end

Dir.glob("#{__dir__}/ys1/*.rb").each { |lib| require(lib) }
