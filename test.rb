Jetmeter::Config.new do |c|
  c.repository_name = 'marchi-martius/FreemarketRn'

  c.register_flow 'Backlog' do |f|
    f.register_addition nil => 'Backlog'
  end

  c.register_flow 'Dev - Ready' do |f|
    f.register_addition 'Backlog' => 'Dev - Ready'
  end

  c.register_flow 'Dev - Working' do |f|
    f.register_addition 'Dev - Ready' => 'Dev - Working'
    f.register_substraction 'Dev - Working' => 'Dev - Ready'
    f.register_substraction 'QA - Ready' => 'Dev - Working'
  end

  c.register_flow 'QA - Ready' do |f|
    f.register_addition 'Dev - Working' => 'QA - Ready'
  end

  c.register_flow 'QA - Working' do |f|
    f.register_addition 'QA - Ready' => 'QA - Working'
  end

  c.register_closing_flow 'Closed'
end
