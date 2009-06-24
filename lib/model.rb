#!/usr/bin/ruby -Ku

class Model
  @@count = -1

  def self.new_dir
    @@count += 1
    "_hmm#{@@count}"
  end

  attr_reader :dir

  def sh(s) system(s) end
  #def sh(s) puts(s) end

  def proto
    num_states = 20
    vec_size = 39
    protohmm(@dir, WORDS, num_states, vec_size) 
    self
  end

  def compv(input, data)
    WORDS.each do |w|
      sh "HCompV -m -M #{@dir} -S #{data} #{input.dir}/#{w}"
    end
    self
  end

  def erest(input, data, label)
    sh "HERest -L #{label} -S #{data} -d #{input.dir} -M #{@dir} -C config/config.herest -s #{@dir}/stats config/models"
    # output : #{@dir}/{newMacros,stats}
    self
  end

  def mixup1(input)
    File.open("_script/mixup.hed", "w") do |f|
      f.puts "LS #{input.dir}/stats"
      f.puts "MU +1 {*.state[2-19].mix}"
    end
    sh "HHEd -H #{input.dir}/newMacros -M #{@dir} _script/mixup.hed config/models"
    self
  end

  def mixup2(input, data, label)
    sh "HERest -L #{label} -S #{data} -H #{input.dir}/newMacros -M #{@dir} -C config/config.herest -s #{@dir}/stats config/models"
    self
  end

  def initialize
    @dir = Model.new_dir
    FileUtils.mkdir_p @dir
  end

  def to_s
    "Model in #{@dir}"
  end
end
