# frozen_string_literal: true

namespace :metrics do
  task :lines do
    lines = 0
    codelines = 0
    total_lines = 0
    total_codelines = 0
    for file_name in FileList['lib/**/*.rb', 'bin/generate-api']
      f = File.open(file_name)
      while line = f.gets
        lines += 1
        next if line.match?(/^\s*$/)
        next if line.match?(/^\s*#/)
        codelines += 1
      end
      puts "L: #{sprintf('%4d', lines)}, " \
           "LOC #{sprintf('%4d', codelines)} | #{file_name}"
      total_lines     += lines
      total_codelines += codelines

      lines = 0
      codelines = 0
    end

    puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
  end
end
