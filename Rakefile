require 'fileutils'

SERVER_NAMES = ['minecraft*.jar', 'craftbukkit*.jar', 'spigot*.jar']
DOTA_WORLD_NAME = 'dota'

task :default => [:server]

desc 'Start up the server'
task :server do
  set_env_defaults
  set_links(ENV['SERVER_DIR'], ENV['WORLDS_DIR'])
  run_server(ENV['START_MEM'], ENV['MAX_MEM'], ENV['GC_THREADS'], ENV['SERVER_DIR'])
end

desc 'Clean out all changed and added files'
task :clean do
  sh 'git reset HEAD --hard'
  sh 'git clean -fd'
end

desc 'Prepare the server for running'
task :build do
  set_env_defaults
  get_worlds(ENV['WORLDS_DIR']) do |world|
    create_backup(world, ENV['BACKUP_DIR'])
  end
  set_links(ENV['SERVER_DIR'], ENV['WORLDS_DIR'])
  exec 'bukin install'
end

desc 'Reset the world and teams back to their original state'
task :reset do
  set_env_defaults
  dota_backup = "#{ENV['BACKUP_DIR']}/#{DOTA_WORLD_NAME}/"
  unless File.directory?(dota_backup)
    abort "Backup of '#{DOTA_WORLD_NAME}' was not found.  Did you forget to run 'rake build'?"
  end
  restore_backup(DOTA_WORLD_NAME, ENV['WORLDS_DIR'], ENV['BACKUP_DIR'])
  FileUtils.rm_rf("#{ENV['SERVER_DIR']}/plugins/SimpleClans/SimpleClans.db")
end

def set_env_defaults
  ENV['START_MEM']  ||= '512M'
  ENV['MAX_MEM']    ||= '1024M'
  ENV['GC_THREADS'] ||= `nproc`.strip
  ENV['WORLDS_DIR'] ||= (ENV['SERVER_DIR'] ? "#{ENV['SERVER_DIR']}/worlds" : 'worlds')
  ENV['BACKUP_DIR'] ||= (ENV['SERVER_DIR'] ? "#{ENV['SERVER_DIR']}/backups" : 'backups')
  ENV['SERVER_DIR'] ||= '.'
end

def get_worlds(world_dir)
  Dir.glob("#{world_dir}/**/level.dat") do |level|
    yield level.chomp('/level.dat')
  end
end

def set_links(server_dir, worlds_dir)
  get_worlds(worlds_dir) do |world_path|
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

def create_backup(world_path, backups_dir)
  world_name = world_path.split('/').last
  FileUtils.mkdir_p(backups_dir)
  FileUtils.rm_rf("#{backups_dir}/#{world_name}")
  FileUtils.cp_r(world_path, backups_dir)
end

def restore_backup(world_name, world_dir, backups_dir)
  FileUtils.rm_rf("#{world_dir}/#{world_name}")
  FileUtils.cp_r("#{backups_dir}/#{world_name}", world_dir)
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
