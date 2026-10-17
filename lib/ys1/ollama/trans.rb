# frozen_string_literal: true

require_relative "../ollama"

module YS1
  # Ollama
  module Ollama
    # Trans provides utility methods for generating prompt templates and translating text.
    module Trans
      # Default model options tuned for translation.
      DEFAULT_OPTIONS = { temperature: 0.4 }.freeze

      class << self
        # Generates the prompt template required for the translation task.
        #
        # @param lang [Symbol] The target language for translation (e.g., :Japanese, :English).
        # @param text [String] The text content to be translated.
        # @return [String] The formatted prompt string.
        def prompt_template(lang, text)
          <<~PROMPT
            #{text}
            ---
            - translate into #{lang}.
            - You must output only the answer itself.
            - Do not add notes, comments, markdown, or formatting.
          PROMPT
        end

        # Translates the given text into the specified language using Ollama.
        #
        # @param lang [Symbol] The target language for translation.
        # @param text [String] The text content to translate.
        # @param model [String] model name used for the request
        # @param options [Hash] extra model options merged over the translation defaults
        # @yieldparam chunk [String] each streamed content chunk
        # @return [String] the full translation
        #
        # @example
        #   YS1::Ollama::Trans.into(:English, "こんにちは") { |chunk| print chunk }
        #   # prints the translation incrementally and returns the full text
        def into(lang, text, model: YS1::Ollama::DEFAULT_MODEL, options: {}, &on_chunk)
          YS1::Ollama.stream(
            prompt_template(lang, text),
            model: model,
            options: DEFAULT_OPTIONS.merge(options),
            &on_chunk
          )
        end
      end
    end
  end
end
