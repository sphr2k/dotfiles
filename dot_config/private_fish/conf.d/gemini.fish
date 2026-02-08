function gemini --wraps gemini --description "Gemini CLI with GitHub token from gh"
  set -gx GITHUB_TOKEN (gh auth token)
  command gemini $argv
end
