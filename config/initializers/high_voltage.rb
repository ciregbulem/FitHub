# config/initializers/high_voltage.rb
HighVoltage.configure do |config|
	config.route_drawer = HighVoltage::RouteDrawers::Root
	config.home_page = 'welcome'
end