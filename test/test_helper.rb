# encoding: UTF-8

require File.join(ENV['HOME'], 'utils/ruby/irb') rescue nil
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__) # test dirs

require 'hangman'

class HangmanTest < Test::Unit::TestCase
  def play_hangman source
     #  require 'pry-debugger';binding.pry
    1.upto(source.number_of_words_to_guess) do |time|
      @hangman = Hangman.new(source)
      @hangman.init_guess

      puts "该单词长度为#{source.word.size}， 可以猜#{source.remain_time} 次。"
      # require 'pry-debugger';binding.pry
      while (!@hangman.done? && !source.remain_time.zero?) || !source.network_success? do # 兼容网络错误
        print "#{source.remain_time}."
        @hangman.guess
        begin
          sleep 3 if not source.network_success?
        rescue Timeout::Error => e
          next
        rescue => e
          e.class; require 'pry-debugger'; binding.pry
          # TODO EOFError: end of file reached
        end
      end; print "\n"

      puts "第#{time}次 #{@hangman.done? ? '成功' : '失败'}"
      puts "依次猜过的#{@hangman.guessed_chars.count}个字母: #{@hangman.guessed_chars.inspect}"
      puts "最终匹配结果 #{@hangman.source.inspect}"
        
      if @hangman.matched_words.count == 1
        puts "猜中的单词是#{@hangman.word}！"
      else
        puts "还没猜完的#{@hangman.matched_words.count}个单词: #{@hangman.matched_words.inspect}"
      end
      puts
    end

    result = source.get_test_results['data']
    total = result['numberOfWordsTried'].to_f
    score = result['numberOfCorrectWords'].to_f
    puts result
    if ((score / total) > 0.75) && (score > @scores.max.to_i)
      source.submit_test_results 
    end if @scores

  end
end

puts "单词长度对应的所有单词总数表"
Hangman::Length_to__words_count_hash.each {|k,v| puts "#{k}:#{v}" }
puts
