# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
#
# Not enabled yet. Revisit in M6 (launch readiness). When enabling, allow
# Google Fonts (fonts.googleapis.com, fonts.gstatic.com) and, in development,
# the Vite dev server:
#
# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#
#     if Rails.env.development?
#       # Allow @vite/client to hot reload JavaScript and style changes
#       policy.script_src(*policy.script_src, :unsafe_eval, "http://#{ViteRuby.config.host_with_port}")
#       policy.style_src(*policy.style_src, :unsafe_inline)
#     end
#
#     policy.script_src(*policy.script_src, :blob) if Rails.env.test?
#   end
# end
