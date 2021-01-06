require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

SimpleCov.start do
  minimum_coverage 5
  add_filter "/.git/"
  add_filter "/.bin/"
  add_filter "/.github/"
  add_filter "/repository/"
  add_filter "/tests/"
end
