#!/usr/bin/ruby -Ku
# rubyhtk by Takuya Nishimoto

class Model
  @@count = 0

  def self.new_dir
    @@count += 1
    "_hmm/#{@@count}"
  end

  def self.proto
    Model.new.proto
  end

  def self.first_train(data, label)
    proto = Model.proto
    m0 = Model.new.compv(proto, data)
    Model.new.erest(m0, data, label)
  end

  attr_reader :dir
  attr_reader :num_mixes

  def initialize(dir = nil)
    if dir == nil
      @dir = Model.new_dir
      FileUtils.mkdir_p @dir
    else
      @dir = dir
    end
  end

  def to_s
    "Model in #{@dir}"
  end

  def sh(s) 
    puts(s)
    system(s) 
  end

  def proto
    num_states = 20
    vec_size = 39
    protohmm(@dir, WORDS, num_states, vec_size) 
    @num_mixes = 1
    self
  end

  def compv(input, data)
    WORDS.each do |w|
      sh "HCompV -m -M #{@dir} -S #{data} #{input.dir}/#{w}"
    end
    @num_mixes = input.num_mixes
    self
  end

  def erest(input, data, label)
    sh "HERest -L #{label} -S #{data} -d #{input.dir} -M #{@dir} -C config/config.herest -s #{@dir}/stats config/models"
    # output : #{@dir}/{newMacros,stats}
    @num_mixes = input.num_mixes
    self
  end

  def mixup1(input)
    File.open("_script/mixup.hed", "w") do |f|
      f.puts "LS #{input.dir}/stats"
      f.puts "MU +1 {*.state[2-19].mix}"
    end
    sh "HHEd -H #{input.dir}/newMacros -M #{@dir} _script/mixup.hed config/models"
    @num_mixes = input.num_mixes + 1
    self
  end

  def mixup2(input, data, label)
    sh "HERest -L #{label} -S #{data} -H #{input.dir}/newMacros -M #{@dir} -C config/config.herest -s #{@dir}/stats config/models"
    @num_mixes = input.num_mixes
    self
  end

  # returns new instance
  def mixup_train(data, label)
    m2 = Model.new.mixup1(self)
    Model.new.mixup2(m2, data, label)
  end

  def vite(data, recout)
    sh "HVite -H #{@dir}/newMacros -S #{data} -w _script/wdnet -i #{recout} config/dict config/models"
  end

end
