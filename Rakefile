SERVER_NAMES = ['minecraft*.jar', 'craftbukkit*.jar', 'spigot*.jar']

task :default => [:server]

desc 'Start up the server'
task :server do
  start_mem = ENV['START_MEM'] || '512M'
  max_mem = ENV['MAX_MEM'] || '1024M'
  gc_threads = ENV['GC_THREADS'] || `nproc`.strip
  server_dir = ENV['SERVER_DIR'] || '.'
  worlds_dir = ENV['WORLDS_DIR'] || (ENV['SERVER_DIR'] ? "#{ENV['SERVER_DIR']}/worlds" : 'worlds')

  set_links(server_dir, worlds_dir)
  run_server(start_mem, max_mem, gc_threads, server_dir)
end

def set_links(server_dir, world_dir)
  Dir.glob("#{world_dir}/**/level.dat") do |level|
    world_path = level.chomp('/level.dat')
    world_name = world_path.split('/').last
    link_path = "#{server_dir}/#{world_name}"

    if !File.exists?(link_path)
      File.symlink(world_path, link_path)
    elsif !File.symlink?(link_path)
      abort "The world '#{world_name}' exists as a file or directory in "\
            "'#{File.expand_path(server_dir)}'.  Please move it to the "\
            "worlds directory."
    end
  end
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
