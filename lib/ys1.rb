# frozen_string_literal: true

require_relative "ys1/version"

Dir.glob("#{__dir__}/ys1/*.rb").each { |lib| require(lib) }
