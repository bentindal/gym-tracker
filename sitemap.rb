require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'http://gymtracker.uk'
SitemapGenerator::Sitemap.create do
  add '/', :changefreq => 'daily', :priority => 0.9
  add '/exercises', :changefreq => 'weekly', :priority => 0.9
  add '/feed', :changefreq => 'weekly', :priority => 0.7
  add '/users/sign_in', :changefreq => 'weekly', :priority => 0.8
  add '/users/sign_up', :changefreq => 'weekly', :priority => 0.8
end
SitemapGenerator::Sitemap.ping_search_engines # Not needed if you use the rake tasks