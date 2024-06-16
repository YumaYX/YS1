# frozen_string_literal: true

require_relative "ys1/version"

module YS1
  class Error < StandardError; end
  # Your code goes here...
end

Dir.glob("#{__dir__}/ys1/*.rb").sort.each { |lib| require(lib) }
