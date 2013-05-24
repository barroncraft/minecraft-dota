SERVER_NAMES = ['minecraft*.jar', 'craftbukkit*.jar', 'spigot*.jar']

task :default => [:server]

desc 'Start up the server'
task :server do
  start_mem = ENV['START_MEM'] || '512M'
  max_mem = ENV['MAX_MEM'] || '1024M'
  gc_threads = ENV['GC_THREADS'] || `nproc`.strip
  directory = ENV['DIRECTORY'] || '.'

  run_server(start_mem, max_mem, gc_threads, directory)
end

def run_server(start_mem, max_mem, gc_threads, directory)

  Dir.chdir(directory)
  servers = Dir.glob(SERVER_NAMES)

  if servers.empty?
    servers = Dir.glob('*.jar')
    if servers.empty?
      abort "No minecraft server (.jar) found in '#{Dir.pwd}'"
    end
  end

  if servers.size > 1
    abort "More than one server (.jar) found in '#{Dir.pwd}'.  "\
          "Please name the file '#{SERVER_NAMES.join("' or '").gsub('*','')}'."
  end

  file_name = servers.first

  command = "java -Xms#{start_mem} "\
                 "-Xmx#{max_mem} "\
                 "-XX:+UseConcMarkSweepGC "\
                 "-XX:+CMSIncrementalPacing "\
                 "-XX:ParallelGCThreads=#{gc_threads} "\
                 "-XX:+AggressiveOpts "\
                 "-jar #{file_name} nogui"

  exec command
end
