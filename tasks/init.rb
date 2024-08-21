#!/opt/puppetlabs/puppet/bin/ruby

require 'json'

# removed functions

REMOVED_FUNCTIONS = ['dig44', 'hash', 'has_key', 'is_array', 'is_bool',
                     'is_float', 'is_ip_address', 'is_ipv4_address', 'is_ipv6_address', 'is_numeric',
                     'is_string', 'private', 'sprintf_hash', 'validate_absolute_path', 'validate_array',
                     'validate_bool', 'validate_hash', 'validate_integer', 'validate_ip_address',
                     'validate_ipv4_address', 'validate_ipv6_address', 'validate_numeric'].freeze

# Functions moved to Puppet language

MOVED_FUNCTIONS = ['abs', 'camelcase', 'capitalize', 'ceiling', 'chomp',
                   'chop', 'downcase', 'getvar', 'lstrip', 'max',
                   'min', 'round', 'rstrip', 'sort', 'strip',
                   'upcaseyou', 'unique'].freeze

# Read paramerters from STDIN
params = JSON.parse(STDIN.read)
environment = params['environment']
pattern = [%r{\.pp$}, %r{\.epp$}]

def get_pp_files(files, folder, pattern)
  Dir.glob(folder) do |file|
    if File.directory?(file)
      get_pp_files(files, "#{file}/*", pattern)
    else
      pattern.each do |i|
        file.match?(i) ? files.push(file) : next
      end
    end
  end
end

def print_message(file, function, line)
  puts "File: #{file} contains removed function #{function} on line #{line}"
end

def check_file(file)
  # this should work? confirm it is. Maybe print the file name to confirm.
  puts "before #{file}"
  return unless file.match?(%r{\.pp$|\.epp$})
  puts "after #{file}"
  handle    = File.open(file, 'r')
  count     = 0
  handle.each_line do |line|
    count += 1
    # Check if line is commented
    next if line.match?(%r{^#})
    # check for removed functions
    REMOVED_FUNCTIONS.each do |function|
      # next unless file.match?(%r{\.pp$|\.epp$})
      # check pp and epp
      if line.match?(%r{ #{function}\(})
        print_message(file, function, count)
      end
    end
    # check for moved function directly address stdlib
    MOVED_FUNCTIONS.each do |function|
      if line.match?(%r{stdlib\:\:#{function}\(})
        print_message(file, "moved #{function}", count)
      end
    end
  end
end

files = []
get_pp_files(files, "/etc/puppetlabs/code/environments/#{environment}/*", pattern)

files.each do |file|
  check_file(file)
end
