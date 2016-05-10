%w(4.1 4.2).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
  end
end

appraise "rails-5-0" do
  gem "rails", "~> 5.0.0.rc1"
end
