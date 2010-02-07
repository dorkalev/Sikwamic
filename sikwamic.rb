require 'rubygems'
require 'rack'
require 'redis'


puts ">> #{REDIS = Redis.new}"

builder = Rack::Builder.new do
  use Rack::CommonLogger

  map '/set' do
    run Proc.new {|env| 
      xxx, action, key, value = env["REQUEST_PATH"].split("/")
      REDIS[key.to_s] = value.to_s
      [200, {"Content-Type" => "text/html"}, value.to_s ]
    }
  end

  map '/get' do
    run Proc.new {|env| 
      xxx, action, key = env["REQUEST_PATH"].split("/")
      [200, {"Content-Type" => "text/html"}, REDIS[key.to_s].to_s ]
    }
  end

  map '/get_if_modified' do
    run Proc.new {|env| 
      xxx, action, key, value = env["REQUEST_PATH"].split("/")
      i = 0
      while ((redis_value = REDIS[key.to_s]) == value.to_s) && (i < 20)
        i += 1
        sleep(0.25)
      end
      [200, {"Content-Type" => "text/html"}, redis_value ]

    }
  end
  puts '>> Sikwamic loaded!'
end

Rack::Handler::Mongrel.run builder, :Port => 9291
