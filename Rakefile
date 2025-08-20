# frozen_string_literal: true

require 'rake'

# Load all rake tasks from lib/tasks
Dir.glob('lib/tasks/*.rake').each { |r| load r }

desc 'Show available tasks'
task :help do
  puts 'Van Gogh Paintings Parser'
  puts '========================='
  puts ''
  puts 'Available tasks:'
  puts '  rake van_gogh:parse[file_path,formatter] - Parse Van Gogh paintings'
  puts '  rake van_gogh:stats[file_path]           - Show parsing statistics'
  puts ''
  puts 'Parameters:'
  puts '  file_path: Path to HTML file (default: files/van-gogh-paintings.html)'
  puts '  formatter: Output format (default: json, available: json)'
  puts ''
  puts 'Examples:'
  puts '  rake van_gogh:parse'
  puts '  rake van_gogh:parse[files/van-gogh-paintings.html]'
  puts '  rake van_gogh:parse[files/van-gogh-paintings.html,json]'
  puts '  rake van_gogh:stats'
end

# Default task
task default: :help
