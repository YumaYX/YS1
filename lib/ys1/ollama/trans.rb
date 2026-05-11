# frozen_string_literal: true

require_relative '../ollama'

module YS1
  module Ollama
    # Trans
    module Trans
      class << self
        def prompt_template(lang, text)
          <<~PROMPT
          #{text}
          ---
          - translate into #{lang.to_s}".
          - You must output only the answer itself.
          - Do not add notes, comments, markdown, or formatting.
          PROMPT
        end

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
