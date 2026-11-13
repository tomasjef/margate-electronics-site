# Idempotent: safe to run again.

# The one admin account. Credentials come from the environment when you run
# the command, and never from the repo.
if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  User.find_or_create_by!(email_address: ENV["ADMIN_EMAIL"]) do |user|
    user.password = ENV["ADMIN_PASSWORD"]
  end
end

# The launch content: adds any launch item not there yet (by slug), leaving
# everything else alone. In development its photos go to R2, so the R2 keys
# must be in .env.
require_relative "seeds/content"
if Rails.env.development? && ENV["R2_ACCESS_KEY_ID"].blank?
  puts "Content not seeded: the R2 keys aren't in .env yet (see .env.example)."
else
  ContentSeeds.run
end
