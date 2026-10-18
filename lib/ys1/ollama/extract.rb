# frozen_string_literal: true

require "json"
require_relative "../ollama"
require_relative "../code_block"

module YS1
  # Ollama
  module Ollama
    # Extract turns free text into structured JSON with an LLM.
    #
    # It follows the same pattern as {YS1::Ollama::Trans} and
    # {YS1::Ollama::OCR}: a prompt template plus a stateless class method.
    module Extract
      # Default model options tuned for structured extraction.
      DEFAULT_OPTIONS = { temperature: 0.2 }.freeze

      class << self
        # Builds the prompt that asks the model to answer with JSON only.
        #
        # @param hint [String] the desired schema or field description
        # @param text [String] the source text to extract from
        # @return [String] the formatted prompt
        #
        # @example
        #   YS1::Ollama::Extract.prompt_template("name, age", "Taro is 20")
        #   # includes the hint and the text
        def prompt_template(hint, text)
          <<~PROMPT
            Extract structured data as JSON.

            Schema / fields:
            #{hint}

            Text:
            #{text}

            Answer with JSON only. Do not add explanations, comments, or Markdown fences.
          PROMPT
        end

        # Extracts structured data from +text+ and parses it as JSON.
        #
        # Stray Markdown fences in the model output are removed with
        # {YS1::CodeBlock.strip} before parsing.
        #
        # @param hint [String] the desired schema or field description
        # @param text [String] the source text to extract from
        # @param model [String] model name
        # @param options [Hash] extra model options merged over the defaults
        # @return [Object] the parsed JSON value
        #
        # @raise [JSON::ParserError] if the model output is not valid JSON
        #
        # @example
        #   YS1::Ollama::Extract.from_text("name, age", "Taro is 20 years old")
        #   # => { "name" => "Taro", "age" => 20 }
        def from_text(hint, text, model: YS1::Ollama::DEFAULT_MODEL, options: {})
          raw = YS1::Ollama.request(
            prompt_template(hint, text),
            model: model,
            options: DEFAULT_OPTIONS.merge(options)
          )

          JSON.parse(YS1::CodeBlock.strip(raw))
        end
      end
    end
  end
end
