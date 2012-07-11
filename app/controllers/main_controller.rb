require 'mdcliapi2'

class MainController < ApplicationController
  skip_before_filter :authorize
  def aboutus
  end

  def contactus
  end

  def zmq
    client = MajorDomoClient.new('tcp://geneva3.godfat.org:5555')
    puts "client connected!"
    requests = 100
    requests.times do |i|
      request = 'Hello world'
      begin
	client.send('echo', request)
        puts "i = #{i}"
      end
    end

    count = 0
    while count < requests do
      begin
	reply = client.recv
        puts "count = #{count}, reply = #{reply}"
      end
      count += 1
    end

    client.close

    @msg = "#{count} requests/replies processed"
    puts "#{count} requests/replies processed"
  end
end
