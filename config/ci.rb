# Run using bin/ci

CI.run do
  # Never migrates the content database (see bin/setup)
  step "Setup", "bin/setup --skip-server --skip-content"

  step "Style: Ruby", "bin/rubocop"
  step "Types: TypeScript", "npm run typecheck"
  step "Build: Vite", "bin/vite build"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Tests: Rails", "bin/rails test"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"

  # The static export, including its check that no page points back at Rails
  # or at this machine (/rails/active_storage, localhost, 127.0.0.1)
  # Built from a copy of the content, migrated to this code: the real file is
  # left as it is (bin/ci-static-build)
  step "Build: static site", "bin/ci-static-build > log/static-build.log"

  # Optional: Run system tests
  # step "Tests: System", "bin/rails test:system"

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end
