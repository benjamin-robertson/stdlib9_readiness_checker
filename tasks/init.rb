#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'hocon'

# removed functions

REMOVED_FUNCTIONS = ['dig44', 'hash', 'has_key', 'is_array', 'is_bool',
                     'is_float', 'is_ip_address', 'is_ipv4_address', 'is_ipv6_address', 'is_numeric',
                     'is_string', 'private', 'sprintf_hash', 'validate_absolute_path', 'validate_array',
                     'validate_bool', 'validate_hash', 'validate_integer', 'validate_ip_address',
                     'validate_ipv4_address', 'validate_ipv6_address', 'validate_numeric', 'type3x',
                     'is_absolute_path', 'validate_string', 'is_integer', 'is_hash', 'validate_re',
                     'validate_slength', 'is_email_address', 'is_mac_address', 'is_domain_name', 'is_function_available'].freeze

# Functions moved to Puppet language

MOVED_FUNCTIONS = ['abs', 'camelcase', 'capitalize', 'ceiling', 'chomp',
                   'chop', 'downcase', 'getvar', 'lstrip', 'max',
                   'min', 'round', 'rstrip', 'sort', 'strip',
                   'upcaseyou', 'unique', 'length', 'empty', 'flatten',
                   'join', 'keys', 'values'].freeze

# Removed data types

REMOVED_DATA_TYPES = ['Stdlib::Compat::Absolute_path', 'Stdlib::Compat::Array', 'Stdlib::Compat::Bool',
                      'Stdlib::Compat::Float', 'Stdlib::Compat::Hash', 'Stdlib::Compat::Integer',
                      'Stdlib::Compat::Ip_address', 'Stdlib::Compat::Ipv4', 'Stdlib::Compat::Ipv6',
                      'Stdlib::Compat::Numeric', 'Stdlib::Compat::String'].freeze

# Deprecated functions. These now use the stdlib::<function> namespace function.
# Need to ensure space is preceeding this function.
DEPRECATED_FUNCTIONS = ['batch_escape', 'ensure_packages', 'fqdn_rand_string', 'has_interface_with',
                        'merge', 'os_version_gte', 'parsehocon', 'parsepson',
                        'powershell_escape', 'seeded_rand', 'seeded_rand_string', 'shell_escape',
                        'to_json', 'to_json_pretty', 'to_python', 'to_ruby',
                        'to_toml', 'to_yaml', 'type_of', 'validate_domain_name',
                        'validate_email_address'].freeze

# Read paramerters from STDIN
params = JSON.parse(STDIN.read)
environment = params['environment']
environment_path = params['environment_path']
check_deprecated = params['check_deprecated']
pattern = [%r{\.pp$}, %r{\.epp$}]

# Get environment dir
if environment_path.nil?
  # load configuration
  config = Hocon.load('/etc/puppetlabs/puppetserver/conf.d/file-sync.conf')
  if config.dig('file-sync', 'repos', 'puppet-code', 'live-dir').nil?
    puts 'Unable to get puppet environment path, please specify path and ensure you are running task on the correct server.'
    exit(1)
  else
    environment_path = "#{config.dig('file-sync', 'repos', 'puppet-code', 'live-dir')}/environments"
  end
end

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

def print_message(file, function, line, status)
  puts "File: #{file} contains #{status} #{function} on line #{line}"
end

def check_file(file, check_deprecated)
  handle    = File.open(file, 'r')
  count     = 0
  handle.each_line do |line|
    count += 1
    # Check if line is commented
    next if line.match?(%r{^#})
    # check for removed functions
    REMOVED_FUNCTIONS.each do |function|
      # check pp and epp
      if line.match?(%r{ #{function}\(})
        print_message(file, function, count, 'removed function')
      end
    end
    # check for moved function directly address stdlib
    MOVED_FUNCTIONS.each do |function|
      if line.match?(%r{stdlib\:\:#{function}\(})
        print_message(file, function, count, 'moved function')
      end
    end
    # check for removed data types
    REMOVED_DATA_TYPES.each do |type|
      if line.match?(%r{#{type}})
        print_message(file, type, count, 'removed type')
      end
    end
    # check for deprecated functions
    next unless check_deprecated
    DEPRECATED_FUNCTIONS.each do |function|
      if line.match?(%r{\h#{function}\(|^#{function}\(})
        print_message(file, function, count, 'deprecated function')
      end
    end
  end
end

files = []
get_pp_files(files, "#{environment_path}/#{environment}/*", pattern)

files.each do |file|
  check_file(file, check_deprecated)
end
