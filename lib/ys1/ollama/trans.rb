# frozen_string_literal: true

require_relative '../ollama'

module YS1
  # Ollama
  module Ollama
    # Trans provides utility methods for generating prompt templates and translating text.
    module Trans
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
          - translate into #{lang.to_s}".
          - You must output only the answer itself.
          - Do not add notes, comments, markdown, or formatting.
          PROMPT
        end

        # Performs the translation of the given text into the specified language using Ollama.
        #
        # @param lang [Symbol] The target language for translation.
        # @param text [String] The text content to translate.
        # @return [void] Streams the result of the translation.
        def into(lang, text)
          YS1::Ollama.data.options.temperature = 0.4
          prompt = prompt_template(lang, text)
          YS1::Ollama.stream(prompt)
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  YS1::Ollama::Trans.into(:Japanese, "hi")
  YS1::Ollama::Trans.into(:English, "こんにちは")
end
