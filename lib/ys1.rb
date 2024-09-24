# frozen_string_literal: true

require_relative "ys1/version"

Dir.glob("#{__dir__}/ys1/*.rb").sort.each { |lib| require(lib) }
